//
//  ChattingAreaDelegator.swift
//  Let's Draw
//
//  Created by apple on 2017/12/29.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import Starscream


//用来实现聊天区相关的方法
class ChattingAreaDelegator:NSObject{
    
    static func sendChattingMessage(message: String, socket: WebSocket, sender me: User) {
        // web socket
        let parameters:[String: Any] = [
            "type": "chattingMessage",
            "playerId": me.id,
            "playerName": me.name,
            "roomId": me.roomId!,
            "messageContent": message
        ]
        let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        socket.write(data: data!)
    }
    
}
