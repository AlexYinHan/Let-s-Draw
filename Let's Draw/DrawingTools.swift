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
        "Red": #colorLiteral(red: 0.8811239004, green: 0.171847105, blue: 0.06758399308, alpha: 1),
        "White": #colorLiteral(red: 0.9998950362, green: 1, blue: 0.9998714328, alpha: 1),
        "Blue": #colorLiteral(red: 0.1415380538, green: 0.5880736113, blue: 0.8526440263, alpha: 1),
        "Green": #colorLiteral(red: 0.363397181, green: 0.9659317136, blue: 0.1169931814, alpha: 1),
        "Yellow": #colorLiteral(red: 0.9523087144, green: 0.9024347663, blue: 0.1591719985, alpha: 1),
        "Purple": #colorLiteral(red: 0.800780952, green: 0.1624049544, blue: 0.4775649905, alpha: 1),
        "Black": #colorLiteral(red: 0.1725263596, green: 0.1725624204, blue: 0.1725212634, alpha: 1)
        ]
}
