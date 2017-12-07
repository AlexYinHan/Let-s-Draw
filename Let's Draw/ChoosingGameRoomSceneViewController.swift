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
    var me: User?
    
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
        var roomId: Int?
        
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/createRoom"
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
                roomId = (data as! [NSDictionary])[0]["roomId"] as? Int
                print((data as! [NSDictionary])[0]["roomId"] as? Int ?? "Wrong room Id returned from server.")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        guard let resultRoomId = roomId else {
            fatalError("No room Id returned from server.")
        }
        return resultRoomId;
    }
}
