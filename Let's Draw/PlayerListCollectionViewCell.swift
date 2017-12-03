//
//  PlayerListCollectionViewCell.swift
//  Let's Draw
//
//  Created by apple on 2017/12/3.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class PlayerListCollectionViewCell: UICollectionViewCell {

    // MARK: Properties
    
    @IBOutlet weak var playerPhoto: UIImageView!
    @IBOutlet weak var playerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
