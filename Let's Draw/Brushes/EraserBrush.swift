//
//  EraserBrush.swift
//  Let's Draw
//
//  Created by apple on 2017/11/8.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class EraserBrush: PencilBrush {

    override func drawInContext(context: CGContext) {
        context.setBlendMode(CGBlendMode.clear)
        
        super.drawInContext(context: context)
    }
    
    override func brushName() -> String {
        return "Eraser"
    }
}
