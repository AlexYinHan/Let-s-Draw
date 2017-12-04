//
//  PrepareSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/25.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log

class PrepareSceneViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK: Properties
    

    @IBOutlet weak var playerList: UICollectionView!
    @IBOutlet weak var readyButton: UIButton!
    
    var players = [Player]()
    var me: Player?
    var roomNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playerList.delegate = self
        playerList.dataSource = self
        
        
        guard let myPlayerInfo = me else {
            fatalError("No information about this player.")
        }
        //把“我”加入玩家列表。实际应该是，在进入这个页面之前，向服务器发信息告知“我”进入了这个房间。由服务器发送消息告知本页面修改玩家列表。
        players.append(myPlayerInfo)
        //测试player List
        let tempPlayer = Player(name: "Edmund", photo: #imageLiteral(resourceName: "People"))
        players.append(tempPlayer!)
        players.append(tempPlayer!)
        players.append(tempPlayer!)
        players.append(tempPlayer!)
        getAllPlayers()
        
        guard let roomNum = roomNumber else {
            fatalError("Unknown room Number.")
        }
        navigationItem.title = "房间号：\(roomNum)"
        playerList.backgroundColor = UIColor.clear  //  要在这里设置透明，在storyboard 中设置的话运行时会变成黑色。
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "WaitingForGameToStart":
            os_log("Waiting for game to start after all players get ready.", log: OSLog.default, type: .debug)
            guard let waitingForGameToStartViewController = segue.destination as? WaitingForGameToStartSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            waitingForGameToStartViewController.me = self.me
            waitingForGameToStartViewController.players = self.players
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    

    //MARK: Private Methods
    
    // Ask the server for the playerList and modify the players array.
    private func getAllPlayers() {
        
    }
}
