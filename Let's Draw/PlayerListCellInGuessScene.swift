//
//  PlayerListCellInGuessScene.swift
//  Let's Draw
//
//  Created by apple on 2017/12/20.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class PlayerListCellInGuessScene: UICollectionViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var playerPhoto: UIImageView!
    @IBOutlet weak var playerName: UILabel!
    
    var answerBubble: UIImageView!
    var answerLabel: UILabel!
    var answerCheck: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let imageFrame = self.playerPhoto.frame
        // wrong answer
        answerBubble = UIImageView(frame: CGRect(x: imageFrame.minX + imageFrame.width*0.25*0.5, y: imageFrame.minY, width: imageFrame.width*0.75, height: 20))
        answerBubble.image = #imageLiteral(resourceName: "Bubble-Red")
        answerLabel = UILabel(frame: answerBubble.frame)
        answerLabel.textAlignment = NSTextAlignment.center
        
        // correct answer
        //answerCheck = UIImageView(frame: answerBubble.frame)
        answerCheck = UIImageView(frame: CGRect(x:answerBubble.frame.midX - 7.5, y: answerBubble.frame.minY, width: 15, height: 15))
        answerCheck.image = #imageLiteral(resourceName: "Check")
        
        answerCheck.isHidden = true
        answerBubble.isHidden = true
        answerLabel.isHidden = true
        
        self.addSubview(answerBubble)
        self.addSubview(answerLabel)
        self.addSubview(answerCheck)
    }
    
}
