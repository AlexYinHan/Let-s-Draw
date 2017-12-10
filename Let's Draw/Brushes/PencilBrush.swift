//
//  PencilBrush.swift
//  Let's Draw
//
//  Created by apple on 2017/11/8.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class PencilBrush: Brush {

    override func drawInContext(context: CGContext) {
        
        let path = CGMutablePath()
        
        // 从lastPoint或者beginPoint开始绘制直线
        if let lastPoint = self.lastPoint {
            path.move(to: lastPoint)
        } else {
            path.move(to: beginPoint)
        }
        
        path.addLine(to: endPoint)
        
        context.addPath(path)
    }
    override func supportContinuousDrawing() -> Bool {
        return true
    }
    
    override func brushName() -> String {
        return "Pencil"
    }
}
