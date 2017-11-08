//
//  DrawingBoard.swift
//  Let's Draw
//
//  Created by apple on 2017/11/8.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
enum DrawingState {
    case Began, Moved, Ended
}

class DrawingBoard: UIImageView {

    var drawingState: DrawingState!
    
    var strokeWidth: CGFloat
    var strokeColor: UIColor
    
    var brush: Brush?
    private var realtimeImage: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        self.strokeColor = UIColor.white
        self.strokeWidth = 1
        
        super.init(coder: aDecoder)
    }
    
    // MARK: touches methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.lastPoint = nil
            brush.beginPoint = touches.first?.location(in: self)
            brush.endPoint = brush.beginPoint
            
            self.drawingState = .Began
            
            self.drawImage()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first?.location(in: self)
            
            self.drawingState = .Moved
            
            self.drawImage()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first?.location(in: self)
            
            self.drawingState = .Ended
            
            self.drawImage()
        }
    }
    
    // MARK: drawing
    
    func drawImage() {
        if let brush = self.brush {
            
            // 设置一个新的ImageContext，用来保存每次的绘图状态
            UIGraphicsBeginImageContext(self.bounds.size)
            
            // 进行context的基本设置
            let context = UIGraphicsGetCurrentContext()
            
            UIColor.clear.setFill()
            UIRectFill(self.bounds)
            
            context?.setLineCap(.round)  //  圆角定点
            context?.setLineWidth(self.strokeWidth)
            context?.setStrokeColor(self.strokeColor.cgColor)
        
        
            // 把之前已经保存的图形绘制到context
            if let realImage = self.realtimeImage {
                realImage.draw(in: self.bounds)
            }
            
            // 设置brush
            brush.strokeWidth = self.strokeWidth
            brush.drawInContext(context: context!)
            context?.strokePath()
            
            // 根据context绘制image
            let previewImage = UIGraphicsGetImageFromCurrentImageContext()
            if self.drawingState == .Ended || brush.supportContinuousDrawing() {
                self.realtimeImage = previewImage
            }
            
            UIGraphicsEndImageContext()
            
            // 显示image
            self.image = previewImage
            
            brush.lastPoint = brush.endPoint
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
