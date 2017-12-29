//
//  DrawMainSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/8.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log
import Alamofire
import Starscream

class DrawMainSceneViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WebSocketDelegate, SendDrawingBoardDelegate {

    // MARK: Properties
    
    @IBOutlet weak var DrawingBoardArea: DrawingBoard!
    @IBOutlet weak var drawingToolMenu: UIView!
    @IBOutlet weak var drawingToolMenuShowButton: UIButton!
    @IBOutlet weak var chattingInputBoxTextField: UITextField!
    @IBOutlet weak var chattingDisplayAreaTextView: UITextView!
    @IBOutlet weak var playerList: UICollectionView!
    
    var me: User?
    var players: [User]!
    var hint: String!
    var keyWord: String!
    
    var socket: WebSocket!
    
    var isDrawingToolMenuDisplayed = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.DrawingBoardArea.brush = DrawingTools.brushes["Pencil"]
        navigationItem.title = "题目：" + keyWord!
        
        // chatting area
        chattingInputBoxTextField.delegate = self
        chattingDisplayAreaTextView.text.append("在这里讨论吧\n")
        chattingDisplayAreaTextView.layoutManager.allowsNonContiguousLayout = false
        
        // player list
        playerList.delegate = self
        playerList.dataSource = self
        let playerListLayout = UICollectionViewFlowLayout.init()
        playerListLayout.itemSize = CGSize(width: 50, height: 70)
        playerListLayout.minimumInteritemSpacing = 10
        playerListLayout.minimumLineSpacing = 10
        playerList.collectionViewLayout = playerListLayout
        
        
        
        self.DrawingBoardArea.sendDrawingBoardDelegate = self
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newChattingRecord = textField.text {
            ChattingAreaDelegator.sendChattingMessage(message: newChattingRecord, socket: self.socket, sender: self.me!)
        }
        // text field归还FirstResponser地位
        // Hide the keyboard.
        textField.resignFirstResponder()
        textField.text = ""
        return true
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "PlayerListCollectionViewCellInGuessScene"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PlayerListCellInGuessScene else {
            fatalError("The dequeued cell is not an instance of PlayerListCollectionViewCell.")
        }
        
        let playerInfo = players[indexPath.row]
        cell.updateView(with: playerInfo)
        
        return cell
    }
    
    // MARK: Actions

    @IBAction func sendMessageBtnPressed(_ sender: UIButton) {
        if let newChattingRecord = chattingInputBoxTextField.text {
            ChattingAreaDelegator.sendChattingMessage(message: newChattingRecord, socket: self.socket, sender: self.me!)
            chattingInputBoxTextField.text = ""
        }
    }
    
    @IBAction func endGameButtonPressed(_ sender: UIBarButtonItem) {
        // 按下结束游戏按钮后，弹出对话框询问是否确认结束
        let endGameAlertController = UIAlertController(title: "结束游戏", message: "确定要结束本局游戏吗？", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "再玩一会儿", style: UIAlertActionStyle.cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default){
            (UIAlertAction) in
            self.endGame()
        }
        endGameAlertController.addAction(cancelAction)
        endGameAlertController.addAction(confirmAction)
        self.present(endGameAlertController, animated: true, completion: nil)
    }
    
    @IBAction func exitGameRoomButtonPressed(_ sender: UIBarButtonItem) {
        // 按下退出房间按钮后，弹出对话框询问是否确认退出
        let exitGameRoomAlertController = UIAlertController(title: "退出房间", message: "你现在是画手，你的退出将导致本局游戏结束，确定吗？", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "再玩一会儿", style: UIAlertActionStyle.cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default){
            (UIAlertAction) in
            self.endGame()
            self.performSegue(withIdentifier: "unwindToChoosingGameRoomScene", sender: self)
        }
        exitGameRoomAlertController.addAction(cancelAction)
        exitGameRoomAlertController.addAction(confirmAction)
        self.present(exitGameRoomAlertController, animated: true, completion: nil)
    }
    
    @IBAction func menuShowButtonPressed(_ sender: UIButton) {
        if isDrawingToolMenuDisplayed {
            UIView.animate(withDuration: 0.3) {
                self.drawingToolMenu.transform = CGAffineTransform(translationX: self.drawingToolMenu.bounds.width - 20, y: 0)
                self.drawingToolMenuShowButton.transform = self.drawingToolMenuShowButton.transform.rotated(by: .pi)
            }
            
        } else {
            UIView.animate(withDuration: 0.3) {
                self.drawingToolMenu.transform = CGAffineTransform(translationX: 0, y: 0)
                self.drawingToolMenuShowButton.transform = self.drawingToolMenuShowButton.transform.rotated(by: .pi)
            }
        }
        isDrawingToolMenuDisplayed = !isDrawingToolMenuDisplayed
        
    }
    
    @IBAction func BrushButtonTapped(_ sender: UIButton) {
        if let brushName = sender.currentTitle {
            self.DrawingBoardArea.brush = DrawingTools.brushes[brushName]
            if(brushName == "Eraser") {
                self.DrawingBoardArea.strokeWidth = 15
            } else {
                self.DrawingBoardArea.strokeWidth = 1
            }
        }
    }
    @IBAction func ColorButtonTapped(_ sender: UIButton) {
        if let colorName = sender.currentTitle, let color = DrawingTools.drawingColors[colorName] {
            self.DrawingBoardArea.strokeColor = color
            self.DrawingBoardArea.colorName = colorName
            self.DrawingBoardArea.brush = DrawingTools.brushes["Pencil"]
            self.DrawingBoardArea.strokeWidth = 1
        }
    }
    
    // MARK: Private methods
    
    private func endGame() {
        // web socket
        let parameters:[String: Any] = [
            "type": "changeGameState",
            "playerId": self.me!.id,
            "roomId": self.me!.roomId!,
            "newGameState": "ended"
        ]
        let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        socket.write(data: data!)
        
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/endGameInRoom?roomId=\(me!.roomId!)"
        let params = NSMutableDictionary()
        var jsonData:Data? = nil
        do {
            jsonData  = try JSONSerialization.data(withJSONObject: params, options:JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            fatalError("Wrong post params when trying to end game.")
        }
        
        // Use semaphore to send Synchronous request
        let semaphore = DispatchSemaphore(value: 0)
        
        ServerConnectionDelegator.httpPost(urlPath: urlPath, httpBody: jsonData!) {
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                if let ok = (data as! [NSDictionary])[0]["ok"] {
                    print("endGame: ok : \(ok)")
                } else {
                    os_log("endGame: unexpected response from server.", log: OSLog.default, type: .debug)
                }
            }
            
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    public func sendDrawingBoard() {
        
        //let semaphore = DispatchSemaphore(value: 0)
            
        let parameters:[String: Any] = [
            "type": "sendDrawingBoard",
            "brushState": self.DrawingBoardArea.drawingState.toString(),
            "brushPositionX": self.DrawingBoardArea.brushPositionX,
            "brushPositionY": self.DrawingBoardArea.brushPositionY,
            "brushKind": self.DrawingBoardArea.brush?.brushName() ?? "default",
            "brushColor": self.DrawingBoardArea.colorName
        ]
        let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        socket.write(data: data!)
        
        /*
            Alamofire.request("http://localhost:3000/tasks/sendDrawingBoard?roomId=\(me!.roomId!)", method: .post, parameters: parameters).responseJSON { response in
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
         */
        
        
    }
    
    private func findPlayer(withId id: Int) -> User? {
        for player in players {
            if player.id == id {
                return player
            }
        }
        return nil
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
                case "ended":
                    performSegue(withIdentifier: "unwindToPrepareScene", sender: self)
                    //print("game is ended")
                //self.performSegue(withIdentifier: "WaitingForGameToStart", sender: self)
                default:
                    print("newGameState should be \(newGameState)")
                }
            }
        case "chattingMessage":
            if let messageText = jsonDict["messageContent"] as? String, let messageSenderName = jsonDict["playerName"] as? String{
                
                self.chattingDisplayAreaTextView.text.append("\(messageSenderName): \(messageText)\n")
                let allStrCount = self.chattingDisplayAreaTextView.text.count //获取总文字个数
                self.chattingDisplayAreaTextView.scrollRangeToVisible(NSMakeRange(0, allStrCount))//把光标位置移到最后
                //print("webSocket receive message \(messageText)")
            }
        case "sendAnswer":
            if let senderId = jsonDict["playerId"] as? Int,
                let sender = findPlayer(withId: senderId),
                let isAnswerCorrect = jsonDict["isCorrect"] as? Bool,
                let answerContent = jsonDict["content"] as? String
                {
                    sender.isAnswerCorrect = isAnswerCorrect
                    sender.answerContent = answerContent
                    self.playerList.reloadData()
                }
        default:
            os_log("Unknown message type.", log: OSLog.default, type: .debug)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}

