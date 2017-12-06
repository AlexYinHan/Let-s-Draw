//
//  DrawMainSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/8.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.DrawingBoardArea.brush = brushes["Pencil"]
        navigationItem.title = "题目：" + KeyWord!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: Actions
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
    
    
}

