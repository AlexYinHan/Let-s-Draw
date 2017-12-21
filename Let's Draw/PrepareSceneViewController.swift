//
//  PrepareSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/25.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log
import Starscream

class PrepareSceneViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, WebSocketDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var playerList: UICollectionView!
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var chattingInputBoxTextField: UITextField!
    @IBOutlet weak var chattingDisplayAreaTextView: UITextView!
    
    var players = [User]()
    var playerIds = [Int]()
    
    var me: User!
    var roomNumber: Int?
    
    var socket:WebSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard me != nil else {
            fatalError("No information about this player.")
        }
        
        // chatting area
        chattingDisplayAreaTextView.text.append("在这里讨论吧\n")
        chattingDisplayAreaTextView.layoutManager.allowsNonContiguousLayout = false
        
        // navigation bar
        guard let roomNum = roomNumber else {
            fatalError("Unknown room Number.")
        }
        navigationItem.title = "房间号：\(roomNum)"
        playerList.backgroundColor = UIColor.clear  //  要在这里设置透明，在storyboard 中设置的话运行时会变成黑色。
        
        // 设置键盘出现时页面上移
        NotificationCenter.default.addObserver(self, selector: #selector(self.kbFrameChanged(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
    }

    // 设置键盘出现时页面上移
    @objc private func kbFrameChanged(_ notification : Notification){
        let info = notification.userInfo
        let kbRect = (info?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let offsetY = kbRect.origin.y - UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: offsetY)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // web socket
        socket.delegate = self
        
        // players
        playerList.delegate = self
        playerList.dataSource = self
        
        // chatting area
        chattingInputBoxTextField.delegate = self
        
        //socket.write(string: "\(self.me.roomId!)")
        // updatePlayerListOperation
        self.getAllPlayers()
        self.playerList.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "PlayerListCollectionViewCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PlayerListCollectionViewCell else {
            fatalError("The dequeued cell is not an instance of PlayerListCollectionViewCell.")
        }
        
        let playerInfo = players[indexPath.row]
        cell.playerName.text = playerInfo.name
        cell.playerPhoto.image = playerInfo.photo
        
        return cell
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newChattingRecord = textField.text {
            sendChattingMessage(message: newChattingRecord)
        }
        // text field归还FirstResponser地位
        // Hide the keyboard.
        textField.resignFirstResponder()
        textField.text = ""
        return true
    }
    
    // MARK: Actions
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        
    }
    @IBAction func readyButtonPressed(_ sender: UIButton) {
        // inform server that the game has begun in this room.
        beginGame()
    }
    
    // MARK: Unwind navigation
    @IBAction func unwindToPrepareScene(sender: UIStoryboardSegue) {
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // 在转移之前取消用于与服务器通信的线程
        //self.queue.cancelAllOperations()
        //isOperationQueueCancelled = true
        
        switch segue.identifier ?? "" {
        case "WaitingForGameToStart":
            os_log("Waiting for game to start after all players get ready.", log: OSLog.default, type: .debug)
            guard let waitingForGameToStartViewController = segue.destination as? WaitingForGameToStartSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            waitingForGameToStartViewController.me = self.me
            waitingForGameToStartViewController.players = self.players
            waitingForGameToStartViewController.socket = self.socket
            
        default:
            // exitButton triggles an unwind segue
            guard let button = sender as? UIButton, button === exitButton else {
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            }
        }
    }
    
    
    

    //MARK: Private Methods
    
    // Ask the server for the playerList and modify the players array.
    private func getAllPlayers() {
        
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/getPlayerIDsInRoom?roomId=\(roomNumber ?? -1)"
        let params = NSMutableDictionary()
        var jsonData:Data? = nil
        do {
            jsonData  = try JSONSerialization.data(withJSONObject: params, options:JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            fatalError("Wrong post params when trying to creat game room.")
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        ServerConnectionDelegator.httpPost(urlPath: urlPath, httpBody: jsonData!) {
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                //print("test")
                //print((data as! [NSDictionary]).count)
                self.playerIds.removeAll()
                for player in (data as! [NSDictionary]) {
                    self.playerIds.append(player["id"] as! Int)
                }
            }
            
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        players.removeAll()
        for player in playerIds {
            let anotherUser = getPlayerInfo(withId: player)
            players.append(anotherUser)
        }
    }
    
    private func getPlayerInfo(withId playerId: Int) ->User {
        var userName: String?
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/getPlayerInfoWithId?playerId=\(playerId)"
        let params = NSMutableDictionary()
        var jsonData:Data? = nil
        do {
            jsonData  = try JSONSerialization.data(withJSONObject: params, options:JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            fatalError("Wrong post params when trying to creat game room.")
        }

        // Use semaphore to send Synchronous request
        let semaphore = DispatchSemaphore(value: 0)
        
        ServerConnectionDelegator.httpPost(urlPath: urlPath, httpBody: jsonData!) {
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                userName = (data as! [NSDictionary])[0]["name"] as? String
            }
            
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        guard let resultUserName = userName else {
            fatalError("No user name returned from server.")
        }
        guard let resultPlayerInfo = User(name: resultUserName, photo: nil) else {
            fatalError("Unrecognized user info returned from server.")
        }
        resultPlayerInfo.id = playerId
        return resultPlayerInfo;
    }
    private func sendChattingMessage(message: String) {
        
        // web socket
        let parameters:[String: Any] = [
            "type": "chattingMessage",
            "playerId": self.me!.id,
            "playerName": self.me!.name,
            "roomId": self.me!.roomId!,
            "messageContent": message
        ]
        let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        socket.write(data: data!)
        
    }
    
    private func beginGame() {
        // web socket
        let parameters:[String: Any] = [
            "type": "changeGameState",
            "playerId": self.me!.id,
            "roomId": self.me!.roomId!,
            "newGameState": "onGoing"
        ]
        let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        socket.write(data: data!)
        
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/beginGameInRoom?roomId=\(me!.roomId!)"
        let params = NSMutableDictionary()
        var jsonData:Data? = nil
        do {
            jsonData  = try JSONSerialization.data(withJSONObject: params, options:JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            fatalError("Wrong post params when trying to begin game.")
        }
        
        // Use semaphore to send Synchronous request
        let semaphore = DispatchSemaphore(value: 0)
        
        ServerConnectionDelegator.httpPost(urlPath: urlPath, httpBody: jsonData!) {
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                if let ok = (data as! [NSDictionary])[0]["ok"] {
                    print("beginGame: ok : \(ok)")
                } else {
                    os_log("beginGame: unexpected response from server.", log: OSLog.default, type: .debug)
                }
            }
            
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    // MARK: - WebSocketDelegate
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        // 1
        guard let data = text.data(using: .utf16),
            let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonData as? [String: Any],
            let messageType = jsonDict["type"] as? String
            else {
                return
        }
        
        // 2
        switch messageType {
        case "chattingMessage":
            if let messageText = jsonDict["messageContent"] as? String, let messageSenderName = jsonDict["playerName"] as? String{
                
                self.chattingDisplayAreaTextView.text.append("\(messageSenderName): \(messageText)\n")
                let allStrCount = self.chattingDisplayAreaTextView.text.count //获取总文字个数
                self.chattingDisplayAreaTextView.scrollRangeToVisible(NSMakeRange(0, allStrCount))//把光标位置移到最后
                //print("webSocket receive message \(messageText)")
            }
        case "joinGameRoom":
            if let anotherPlayerId = jsonDict["playerId"] as? Int {
                let anotherUser = getPlayerInfo(withId: anotherPlayerId)
                players.append(anotherUser)
                self.playerList.reloadData()
            }
        case "exitGameRoom":
            if let removedPlayerId = jsonDict["playerId"] as? Int {
                let updatedPlayers = players.filter{ $0.id != removedPlayerId }
                players = updatedPlayers
                self.playerList.reloadData()
            }
        case "changeGameState":
            if let newGameState = jsonDict["newGameState"] as? String {
                switch newGameState {
                    /*
                     0: ended
                     1: readyToBegin
                     2: onGoing
                     */
                case "onGoing":
                    self.performSegue(withIdentifier: "WaitingForGameToStart", sender: self)
                default:
                    print("newGameState should be \(newGameState)")
                }
            }
        default:
            os_log("Unknown message type.", log: OSLog.default, type: .debug)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
