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

    var me: User?
    var KeyWord: String!
    
    var isOperationQueueCancelled = false
    var queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.DrawingBoardArea.brush = DrawingTools.brushes["Pencil"]
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
                //sleep(1)
            }
        })
        sendDrawingBoardOperation.completionBlock = {
            print("sendDrawingBoardOperation completed.")
        }
        //self.queue.addOperation(sendDrawingBoardOperation)
         
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
    
    private func sendDrawingBoard() {
        
            let semaphore = DispatchSemaphore(value: 0)
            
            let parameters:[String: Any] = [
                "brushState": self.DrawingBoardArea.drawingState,
                "brushPositionX": self.DrawingBoardArea.brushPositionX,
                "brushPositionY": self.DrawingBoardArea.brushPositionY,
                "brushKind": self.DrawingBoardArea.brush?.brushName() ?? "default",
                "brushColor": self.DrawingBoardArea.colorName
            ]
            Alamofire.request("http://localhost:3000/tasks/sendDrawingBoard?roomId=\(me!.roomId!)", method: .post, parameters: parameters).responseJSON { response in
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        
    }
    
    
}

