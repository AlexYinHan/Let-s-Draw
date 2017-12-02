//
//  PrepareSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/25.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class PrepareSceneViewController: UIViewController {

    @IBOutlet weak var readyButton: UIButton!
    //MARK: Properties
    var players = [Player]()
    var me: Player?
    var roomNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        guard let myPlayerInfo = me else {
            fatalError("No information about this player.")
        }
        //把“我”加入玩家列表。实际应该是，在进入这个页面之前，向服务器发信息告知“我”进入了这个房间。由服务器发送消息告知本页面修改玩家列表。
        players.append(myPlayerInfo)
        
        getAllPlayers()
        
        guard let roomNum = roomNumber else {
            fatalError("Unknown room Number.")
        }
        navigationItem.title = "房间号：\(roomNum)"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Private Methods
    
    // Ask the server for the playerList and modify the players array.
    private func getAllPlayers() {
        
    }
}
