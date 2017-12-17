//
//  WaitingForGameToStartSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/12/2.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log
import Starscream

enum PlayerRole {
    case Drawer
    case Guesser
}
class WaitingForGameToStartSceneViewController: UIViewController {

    // MARK: Properties
    var players = [User]()
    var me: User?
    var Subject:String!
    var socket: WebSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // segue to Draw/Guess scene according to player role.
        if let myPlayerInfo = me {
            let playerRole = getPlayerRole(Player: myPlayerInfo)
            switch playerRole {
            case .Drawer:
                os_log("Entering draw scene.", log: OSLog.default, type: .debug)
                Subject = getKeyWord()
                performSegue(withIdentifier: "EnterDrawScene", sender: self)
            case .Guesser:
                os_log("Entering guess scene.", log: OSLog.default, type: .debug)
                Subject = getHint()
                performSegue(withIdentifier: "EnterGuessScene", sender: self)
                /*
                 default:
                 fatalError("Unexpected Player Role; \(String(describing: playerRole))")
                 */
            }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "EnterGuessScene":
            guard let guessMainSceneNavigationController = segue.destination as? UINavigationController, let guessMainSceneViewController = guessMainSceneNavigationController.topViewController as? GuessMainSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guessMainSceneViewController.me = self.me
            guessMainSceneViewController.Hint = self.Subject
            guessMainSceneViewController.socket = self.socket
            
        case "EnterDrawScene":
            guard let drawMainSceneNavigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let drawMainSceneViewController = drawMainSceneNavigationController.topViewController as? DrawMainSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            drawMainSceneViewController.me = self.me
            drawMainSceneViewController.KeyWord = self.Subject
            drawMainSceneViewController.socket = self.socket
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    // MARK: Private Methods
    
    // Ask the the server for the key word for the game.
    private func getKeyWord() -> String {
        let urlPath: String = "http://localhost:3000/tasks/getKeyWordInRoom?roomId=\(me?.roomId ?? 0)"
        let url = URL(string: urlPath)!
        let request = URLRequest(url: url)
        
        var keyWord:String = ""
        
        // Use semaphore to send Synchronous request
        let semaphore = DispatchSemaphore(value: 0)
        
        ServerConnectionDelegator.httpGet(request: request){
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                print("keyWord data:\(data)")
                keyWord = data
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return keyWord
    }
    
    private func getHint() -> String {
        let urlPath: String = "http://localhost:3000/tasks/getHintInRoom?roomId=\(me?.roomId ?? 0)"
        let url = URL(string: urlPath)!
        let request = URLRequest(url: url)
        
        var hint:String = ""
        
        // Use semaphore to send Synchronous request
        let semaphore = DispatchSemaphore(value: 0)
        
        ServerConnectionDelegator.httpGet(request: request){
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                print("hint data:\(data)")
                hint = data
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return hint
    }
    
    private func getPlayerRole(Player: User) -> PlayerRole{
        let urlPath: String = "http://localhost:3000/tasks/playerRole?roomId=\(me!.roomId!)&playerId=\(me!.id)"
        let url = URL(string: urlPath)!
        let request = URLRequest(url: url)
        
        var playerRole:String = ""
        
        // Use semaphore to send Synchronous request
        let semaphore = DispatchSemaphore(value: 0)
        
        ServerConnectionDelegator.httpGet(request: request){
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                print("player role data:\(data)")
                playerRole = data
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        switch playerRole {
        case "Guesser":
            return PlayerRole.Guesser
        case "Drawer":
            return PlayerRole.Drawer
        default:
            fatalError("\(playerRole):Unrecognized player role returned from server.")
        }
    }

}





