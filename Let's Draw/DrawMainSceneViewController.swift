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

class DrawMainSceneViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var DrawingBoardArea: DrawingBoard!
    
    // 所有笔刷
    var brushes = [
        "Pencil": PencilBrush(),
        "Eraser": EraserBrush(),
    ]
    var drawingColors = [
        "Red": UIColor.red,
        "White": UIColor.white,
    ]

    var me: User?
    var KeyWord: String!
    
    var isOperationQueueCancelled = false
    var queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.DrawingBoardArea.brush = brushes["Pencil"]
        navigationItem.title = "题目：" + KeyWord!
    }

    override func viewDidAppear(_ animated: Bool) {
        /*
        while true {
            self.sendDrawingBoard()
            sleep(1)
        }
         */
        
        // sendDrawingBoardOperation
        let sendDrawingBoardOperation = BlockOperation(block: {
            //print("updateChattingArea")
            while true {
                if self.isOperationQueueCancelled {
                    break
                }
                
                self.sendDrawingBoard()
                sleep(1)
            }
        })
        sendDrawingBoardOperation.completionBlock = {
            print("sendDrawingBoardOperation completed.")
        }
        self.queue.addOperation(sendDrawingBoardOperation)
         
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: Actions
    @IBAction func panGestureOnDrawingboard(_ sender: UIPanGestureRecognizer) {
    }
    @IBAction func BrushButtonTapped(_ sender: UIButton) {
        if let brushName = sender.currentTitle {
            self.DrawingBoardArea.brush = brushes[brushName]
            if(brushName == "Eraser") {
                self.DrawingBoardArea.strokeWidth = 15
            } else {
                self.DrawingBoardArea.strokeWidth = 1
            }
        }
    }
    @IBAction func ColorButtonTapped(_ sender: UIButton) {
        if let colorName = sender.currentTitle, let color = drawingColors[colorName] {
            self.DrawingBoardArea.strokeColor = color
        }
    }
    
    // MARK: Private methods
    
    private func sendDrawingBoard() {
        //Alamofire.request(<#T##url: URLConvertible##URLConvertible#>)
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/sendDrawingBoard?roomId=\(me!.roomId!)"
        /*let params = NSMutableDictionary()
        var jsonData:Data? = nil
        do {
            jsonData  = try JSONSerialization.data(withJSONObject: params, options:JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            fatalError("Wrong post params when trying to creat game room.")
        }
        */
        if let image = DrawingBoardArea.realtimeImage, let data = UIImagePNGRepresentation(image) {
            print(data)
            // Use semaphore to send Synchronous request
            //let semaphore = DispatchSemaphore(value: 0)
            
            ServerConnectionDelegator.httpPost(urlPath: urlPath, httpBody: data) {
                (data, error) -> Void in
                if error != nil {
                    print(error!)
                } else {
                    if let ok = (data as? [String]) {
                        print(ok)
                    }
                }
                
                //semaphore.signal()
            }
            //_ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        
    }
    
    
}

