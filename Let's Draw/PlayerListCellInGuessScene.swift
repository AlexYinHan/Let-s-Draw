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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        answerBubble = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.maxX, height: 20))
        answerBubble.image = #imageLiteral(resourceName: "Bubble")
        answerLabel = UILabel(frame: answerBubble.bounds)
        answerLabel.textAlignment = NSTextAlignment.center
        answerLabel.isHidden = true
        self.addSubview(answerBubble)
        self.addSubview(answerLabel)
    }
    
}
