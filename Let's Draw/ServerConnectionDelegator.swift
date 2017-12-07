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
                //  UTF-8编码，传输中文
                let result = NSString(data: data!, encoding:
                    String.Encoding.utf8.rawValue)!
                callback(result as String, nil)
            }
        }
        task.resume()
    }
    
    static public func httpPost(urlPath: String, httpBody: Data, callback: @escaping ([Any]?, String?) -> Void) {
        let session = URLSession.shared
        let url = URL(string: urlPath)!
        //NSMutableURLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            if error != nil {
                callback(nil, error!.localizedDescription)
            } else {
                var dict = [Any]()
                do {
                    dict  = (try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? [Any])!
                    //dict  = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                } catch {
                    
                }
                print("post res from server: ",dict)
                callback(dict, nil)
            }
        }
        task.resume()
    }
    
}
