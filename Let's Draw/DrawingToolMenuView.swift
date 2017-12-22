//
//  DrawingToolMenuView.swift
//  Let's Draw
//
//  Created by apple on 2017/12/22.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class DrawingToolMenuView: UIView {

    var backGroundImage = UIImageView(image: #imageLiteral(resourceName: "MenuFrame"))
    var brushColors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)]
    var brushColorButtons = [UIButton]()
    var brushColorStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for color in brushColors {
            let brushColorButton = UIButton(type: .custom)
            brushColorButton.backgroundColor = color
            brushColorButton.layer.cornerRadius = brushColorButton.frame.width/2
            brushColorButton.layer.masksToBounds = true
            brushColorButton.layer.borderWidth = 3.0
            brushColorButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            brushColorButton.addTarget(self, action: #selector(self.tmpFunction(_:)), for: .touchUpInside)
            brushColorButtons.append(brushColorButton)
        }
        
        let brushColorStackView = UIStackView(arrangedSubviews: brushColorButtons)
        brushColorStackView.frame = CGRect(x: 20, y: 30, width: self.bounds.width - 20, height: self.frame.height - 30)
        brushColorStackView.axis = .horizontal
        brushColorStackView.distribution = .fillEqually
        //brushColorStackView.spacing = 10
        //brushColorStackView.alignment = .fill
        
        //tmpButton.add
        //self.addSubview(tmpButton)
        
        self.addSubview(backGroundImage)
        self.addSubview(brushColorStackView)
    }
    
    @objc private func tmpFunction(_ sender: UIButton!) {
        print("here!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addSubview(backGroundImage)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
