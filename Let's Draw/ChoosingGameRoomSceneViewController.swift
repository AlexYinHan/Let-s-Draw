//
//  ChoosingGameRoomSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/12/2.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log

class ChoosingGameRoomSceneViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var me: Player?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let myPlayerInfo = me else {
            fatalError("No information about this player.")
        }
        userName.text = myPlayerInfo.name
        if let myPlayerPhoto = myPlayerInfo.photo {
            userPhoto.image = myPlayerPhoto
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "EnterGameRoom":
            guard let prepareSceneNavigationController = segue.destination as? UINavigationController, let prepareSceneViewController = prepareSceneNavigationController.topViewController as? PrepareSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            prepareSceneViewController.me = self.me
            prepareSceneViewController.roomNumber = createGameRoom()
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
 

    // MARK: Private Methods
    
    // Ask the server to create a new game room and return the number of the new room.
    private func createGameRoom() -> Int {
        // Connect the server
        // ...
        
        return 1001;
    }
}
