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
    
    @IBOutlet weak var pencilImage: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var players: [User]!
    var me: User?
    var keyWord: String!
    var hint: String!
    var socket: WebSocket!
    var isFirst = true // 第一次进入该场景，为了在unwind经过本页面时进行判断
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket?.delegate = nil // 这个场景中不需要代理socket
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isFirst {
            isFirst = false
        } else {
            return
        }
        
        UIView.transition(
            with: self.view,
            duration: 0.5,
            options: [],
            animations: {
                [unowned  self] in
                self.progressBar.transform = CGAffineTransform(scaleX: 1.0, y: 5.0)
                //self.pencilImage.transform = self.pencilImage.transform.rotated(by: -CGFloat.pi/4)
                self.pencilImage.transform = self.pencilImage.transform.translatedBy(x: self.progressBar.frame.minX - self.pencilImage.frame.minX, y: self.progressBar.frame.minY - self.pencilImage.frame.maxY)
            },
            completion: {
                [unowned self] (finished:Bool) -> Void in
                self.connectProgress()
            }
        )
        
    }
    
    private func connectProgress() {
        // ask server for info in game and update process bar
        if let myPlayerInfo = self.me {
            let playerRole = self.getPlayerRole(Player: myPlayerInfo)
            self.progressBar.setProgress(0.3, animated: true)
            UIView.animate(
                withDuration: 0.3,
                animations: { [unowned self] in
                    self.pencilImage.transform = self.pencilImage.transform.translatedBy(x: 0.3*self.progressBar.frame.width, y: 0)
                },
                completion: {
                    [unowned self] (finished:Bool) -> Void in
                    self.hint = self.getHint()
                    self.progressBar.setProgress(0.6, animated: true)
                    UIView.animate(
                        withDuration: 0.3,
                        animations: { [unowned self] in
                            self.pencilImage.transform = self.pencilImage.transform.translatedBy(x: 0.3*self.progressBar.frame.width, y: 0)
                        },
                        completion: {
                            [unowned self] (finished:Bool) -> Void in
                            self.keyWord = self.getKeyWord()
                            self.progressBar.setProgress(1, animated: true)
                            UIView.animate(
                                withDuration: 0.3,
                                animations: { [unowned self] in
                                    self.pencilImage.transform = self.pencilImage.transform.translatedBy(x: 0.4*self.progressBar.frame.width, y: 0)
                                },
                                completion: {
                                    [unowned self] (finished:Bool) -> Void in
                                    //segue to Draw/Guess scene according to player role.
                                    switch playerRole {
                                    case .Drawer:
                                        os_log("Entering draw scene.", log: OSLog.default, type: .debug)
                                        self.performSegue(withIdentifier: "EnterDrawScene", sender: self)
                                    case .Guesser:
                                        os_log("Entering guess scene.", log: OSLog.default, type: .debug)
                                        self.performSegue(withIdentifier: "EnterGuessScene", sender: self)
                                    }
                                }// completion for getKeyWord process
                            )
                        }// completion for getHintWord process
                    )
                }// completion for getPlayerRole process
            )
            
        }
    }
    
    // MARK: Unwind navigation
    @IBAction func unwindToWaitingForGameToStartScene(sender: UIStoryboardSegue) {
        performSegue(withIdentifier: "unwindToChoosingGameRoomScene", sender: self)
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
            guessMainSceneViewController.players = self.players
            guessMainSceneViewController.hint = self.hint
            guessMainSceneViewController.keyWord = self.keyWord
            guessMainSceneViewController.socket = self.socket
            
        case "EnterDrawScene":
            guard let drawMainSceneNavigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let drawMainSceneViewController = drawMainSceneNavigationController.topViewController as? DrawMainSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            drawMainSceneViewController.me = self.me
            drawMainSceneViewController.players = self.players
            drawMainSceneViewController.hint = self.hint
            drawMainSceneViewController.keyWord = self.keyWord
            drawMainSceneViewController.socket = self.socket
            
        case "unwindToChoosingGameRoomScene":
            break
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





