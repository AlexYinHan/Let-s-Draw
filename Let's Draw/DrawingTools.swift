//
//  DrawingTools.swift
//  Let's Draw
//
//  Created by apple on 2017/12/10.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class DrawingTools: NSObject {

    static var brushes = [
        "Pencil": PencilBrush(),
        "Eraser": EraserBrush(),
        ]
    
    static var drawingColors = [
        "Red": UIColor.red,
        "White": UIColor.white,
        ]
}
