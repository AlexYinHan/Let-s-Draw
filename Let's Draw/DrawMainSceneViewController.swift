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

class DrawMainSceneViewController: UIViewController, WebSocketDelegate, SendDrawingBoardDelegate {

    // MARK: Properties
    
    @IBOutlet weak var DrawingBoardArea: DrawingBoard!

    var me: User?
    var KeyWord: String!
    
    var socket: WebSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.DrawingBoardArea.brush = DrawingTools.brushes["Pencil"]
        navigationItem.title = "题目：" + KeyWord!
        
        // web socket
        socket.delegate = self
        
        self.DrawingBoardArea.sendDrawingBoardDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: Actions

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
        }
    }
    
    // MARK: Private methods
    
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
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    
}

