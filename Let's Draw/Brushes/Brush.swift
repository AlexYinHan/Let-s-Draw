//
//  Brush.swift
//  Let's Draw
//
//  Created by apple on 2017/11/8.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

protocol PaintBrush {
    func supportContinuousDrawing() -> Bool
    func drawInContext(context: CGContext)
}

class Brush: NSObject, PaintBrush {
    
    // points
    var beginPoint: CGPoint!
    var endPoint: CGPoint!  //  除了铅笔，每次从beginPoint画到endPoint
    var lastPoint: CGPoint? //  使用铅笔工具进行连续作画时，每次从lastPoint画到endPoint
    
    // features
    var strokeWidth: CGFloat!
    
    func supportContinuousDrawing() -> Bool {
        return false
    }
    
    func drawInContext(context: CGContext) {
        assert(false, "func drawInContext(context: CGContext) Should be implemented in subclass.")
    }
}
