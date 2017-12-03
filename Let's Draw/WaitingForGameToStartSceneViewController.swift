//
//  WaitingForGameToStartSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/12/2.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log

enum PlayerRole {
    case Drawer
    case Guesser
}
class WaitingForGameToStartSceneViewController: UIViewController {

    // MARK: Properties
    var players = [Player]()
    var me: Player?
    var Subject:String!
    
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
            
        case "EnterDrawScene":
            guard let drawMainSceneNavigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let drawMainSceneViewController = drawMainSceneNavigationController.topViewController as? DrawMainSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            drawMainSceneViewController.me = self.me
            drawMainSceneViewController.KeyWord = self.Subject
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    // MARK: Private Methods
    
    // Ask the the server for the key word for the game.
    private func getKeyWord() -> String {
        // ...
        return String("直尺")
    }
    
    private func getHint() -> String {
        // ...
        return String("文具")
    }
    
    private func getPlayerRole(Player: Player) -> PlayerRole{
        
        return .Guesser
    }

}
