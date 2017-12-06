//
//  ServerConnectionDelegator.swift
//  Let's Draw
//
//  Created by apple on 2017/12/6.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

// 用来完成与服务器通信有关的功能
class ServerConnectionDelegator: NSObject {

    static public func httpGet(request: URLRequest!, callback: @escaping (String, String?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
            if error != nil {
                callback("", error!.localizedDescription)
            } else {
                let result = NSString(data: data!, encoding:
                    String.Encoding.ascii.rawValue)!
                callback(result as String, nil)
            }
        }
        task.resume()
    }
    
}
