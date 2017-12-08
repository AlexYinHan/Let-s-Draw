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
    var me: User?
    var roomNumber: Int?
    
    var queue = OperationQueue()
    //var updatePlayerListOperation: BlockOperation?
    var updatePlayerListOperationIsCancelled = false
    
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
            print("update")
            while true {
                if self.updatePlayerListOperationIsCancelled {
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
        
        queue.addOperation(updatePlayerListOperation)
        //queue.cancelAllOperations()
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
            chattingDisplayAreaTextView.text.append("\n\(newChattingRecord)")
            let allStrCount = chattingDisplayAreaTextView.text.count //获取总文字个数
            chattingDisplayAreaTextView.scrollRangeToVisible(NSMakeRange(0, allStrCount))//把光标位置移到最后
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
        
        // 在转移之前取消更新playerList的线程
        self.queue.cancelAllOperations()
        updatePlayerListOperationIsCancelled = true
        
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
        let urlPath: String = "http://localhost:3000/tasks/getPlayersInRoom?roomId=\(roomNumber ?? -1)"
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
                print("test")
                print((data as! [NSDictionary]).count)
                self.players.removeAll()
                for player in (data as! [NSDictionary]) {
                    if let actualPlayer = User(name: player["name"] as! String, photo: nil) {
                        self.players.append(actualPlayer)
                    }
                }
            }
            
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
}
