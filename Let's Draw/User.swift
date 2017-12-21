//
//  Player.swift
//  Let's Draw
//
//  Created by apple on 2017/11/30.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class User: NSObject {

    //MARK: Properties
    
    var id: Int
    var name: String
    var photo: UIImage?
    var roomId: Int?
    
    // only useful when actually gaming
    var isAnswerCorrect: Bool?
    var answerContent: String?
    //var score: Int?
    
    //MARK: Initialization
    init?(name: String, photo: UIImage?) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize
        self.name = name
        if let userPhoto = photo {
            self.photo = userPhoto
        } else {
            self.photo = #imageLiteral(resourceName: "People");
        }
        
        id = 0;
        
    }
}
