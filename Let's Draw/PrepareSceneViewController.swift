//
//  PrepareSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/25.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log

class PrepareSceneViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    //MARK: Properties
    

    @IBOutlet weak var playerList: UICollectionView!
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var chattingInputBoxTextField: UITextField!
    @IBOutlet weak var chattingDisplayAreaTextView: UITextView!
    
    var players = [User]()
    var playerIds = [Int]()
    
    var me: User?
    var roomNumber: Int?
    
    var queue = OperationQueue()
    //var updatePlayerListOperation: BlockOperation?
    var isOperationQueueCancelled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playerList.delegate = self
        playerList.dataSource = self
        
        
        guard me != nil else {
            fatalError("No information about this player.")
        }
        
        // chatting area
        chattingInputBoxTextField.delegate = self
        chattingDisplayAreaTextView.text.append("在这里讨论吧\n")
        chattingDisplayAreaTextView.layoutManager.allowsNonContiguousLayout = false
        
        // navigation bar
        guard let roomNum = roomNumber else {
            fatalError("Unknown room Number.")
        }
        navigationItem.title = "房间号：\(roomNum)"
        playerList.backgroundColor = UIColor.clear  //  要在这里设置透明，在storyboard 中设置的话运行时会变成黑色。
        
    }

    override func viewDidAppear(_ animated: Bool) {
        // updatePlayerListOperation
        let updatePlayerListOperation = BlockOperation(block: {
            print("updatePlayerList")
            while true {
                if self.isOperationQueueCancelled {
                    break
                }
                self.getAllPlayers()
                OperationQueue.main.addOperation {
                    self.playerList.reloadData()
                }
                sleep(1)
            }
        })
        updatePlayerListOperation.completionBlock = {
            print("updatePlayerListOperation completed.")
        }
        
        // updateChattingAreaOperation
        let updateChattingAreaOperation = BlockOperation(block: {
            //print("updateChattingArea")
            while true {
                if self.isOperationQueueCancelled {
                    break
                }
                
                let newMessage = self.getChattingMessage()
                
                OperationQueue.main.addOperation {
                    // 更新聊天区
                    self.chattingDisplayAreaTextView.text.append("\n\(newMessage)")
                    let allStrCount = self.chattingDisplayAreaTextView.text.count //获取总文字个数
                    self.chattingDisplayAreaTextView.scrollRangeToVisible(NSMakeRange(0, allStrCount))//把光标位置移到最后
                }
                sleep(1)
            }
        })
        updateChattingAreaOperation.completionBlock = {
            print("updateChattingAreaOperation completed.")
        }
        
        queue.addOperation(updatePlayerListOperation)
        queue.addOperation(updateChattingAreaOperation)
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // 在转移之前取消用于与服务器通信的线程
        self.queue.cancelAllOperations()
        isOperationQueueCancelled = true
        
        switch segue.identifier ?? "" {
        case "WaitingForGameToStart":
            os_log("Waiting for game to start after all players get ready.", log: OSLog.default, type: .debug)
            guard let waitingForGameToStartViewController = segue.destination as? WaitingForGameToStartSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            waitingForGameToStartViewController.me = self.me
            waitingForGameToStartViewController.players = self.players
            
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
        /*
        struct PlayerInfo {
            var name: String
            var photo = 0   //  暂时是Int，应该是image
        }
        */
        // Use semaphore to send Synchronous request
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
        /*
         struct PlayerInfo {
         var name: String
         var photo = 0   //  暂时是Int，应该是image
         }
         */
        // Use semaphore to send Synchronous request
        let semaphore = DispatchSemaphore(value: 0)
        
        ServerConnectionDelegator.httpPost(urlPath: urlPath, httpBody: jsonData!) {
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                //print("test")
                //print((data as! [NSDictionary]).count)
                //let userId = (data as! [NSDictionary])[0]["Id"] as? Int
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
        return resultPlayerInfo;
    }
    private func sendChattingMessage(message: String) {
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/sendChattingMessageInRoom?roomId=\(roomNumber ?? -1)&\(me!.name)&\(message)"
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
                if let ok = (data as! [NSDictionary])[0]["ok"] {
                    print("sendChattingMessage: ok : \(ok)")
                } else {
                    os_log("sendChattingMessage: unexpected response from server.", log: OSLog.default, type: .debug)
                }
            }
            
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    private func getChattingMessage() ->String {
        var result = ""
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/getChattingMessageInRoom?roomId=\(roomNumber ?? -1)"
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
                for message in (data as! [String]) {
                    result += message
                }
            }
            
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return result
    }
}
