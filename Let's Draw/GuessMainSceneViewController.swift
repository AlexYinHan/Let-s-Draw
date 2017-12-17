//
//  GuessMainSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/25.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log
import Alamofire
import Starscream

class GuessMainSceneViewController: UIViewController, UITextFieldDelegate, WebSocketDelegate {

    //MARK: Properties
    @IBOutlet weak var chattingInputBoxTextField: UITextField!
    @IBOutlet weak var chattingDisplayAreaTextView: UITextView!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var renderingBoardArea: RenderingBoard!
    
    var Hint: String!
    var me: User?
    
    var socket: WebSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        navigationItem.title = "提示：" + Hint!
        
        // chatting area
        chattingInputBoxTextField.delegate = self
        chattingDisplayAreaTextView.text.append("在这里讨论吧\n")
        chattingDisplayAreaTextView.layoutManager.allowsNonContiguousLayout = false
        
        // answer button
        answerButton.layer.cornerRadius = 5 //  设置为圆角按钮
        
        // web socket
        socket.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newChattingRecord = textField.text {
            chattingDisplayAreaTextView.text.append("\n\(newChattingRecord)")
            let allStrCount = chattingDisplayAreaTextView.text.count //获取总文字个数
            chattingDisplayAreaTextView.scrollRangeToVisible(NSMakeRange(0, allStrCount))//把光标位置移到最后
        }
        // text field归还FirstResponser地位
        // Hide the keyboard.
        textField.resignFirstResponder()
        textField.text = ""
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Actions
    @IBAction func answerButtonPressed(_ sender: UIButton) {
        // 按下回答按钮后，弹出一个对话框用于输入答案
        let answerAlertController = UIAlertController(title: "回答", message: "", preferredStyle: UIAlertControllerStyle.alert)
        answerAlertController.addTextField(configurationHandler: {
            (textField:UITextField) -> Void in
                textField.placeholder = "请输入你的答案"
            })
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: {
            (UIAlertAction) in
                // 提交答案
            if let answer = (answerAlertController.textFields!.first as UITextField?)?.text
            {
                print("[GuessMainScene]Confirm answer:\(answer).")
            }
            })
        answerAlertController.addAction(cancelAction)
        answerAlertController.addAction(confirmAction)
        self.present(answerAlertController, animated: true, completion: nil)
    }
    
    // MARK: - WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        // 1
        guard let data = text.data(using: .utf16),
            let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonData as? [String: Any],
            let messageType = jsonDict["type"] as? String
            else {
                return
        }
        
        // 2
        switch messageType {
        case "sendDrawingBoard":
            // 画笔颜色
            if let colorName = jsonDict["brushColor"] as? String, let color = DrawingTools.drawingColors[colorName] {
                self.renderingBoardArea.strokeColor = color
            } else {
                os_log("Failed to get brush color.", log: OSLog.default, type: .debug)
            }
            // 画笔种类
            if let brushName = jsonDict["brushKind"] as? String {
                self.renderingBoardArea.brush = DrawingTools.brushes[brushName]
                if brushName == "Eraser" {
                    self.renderingBoardArea.strokeWidth = 15
                } else {
                    self.renderingBoardArea.strokeWidth = 1
                }
            } else {
                os_log("Failed to get brush name.", log: OSLog.default, type: .debug)
            }
            
            // 画
            if let brushState = jsonDict["brushState"] as? String, let x = jsonDict["brushPositionX"] as? CGFloat, let y = jsonDict["brushPositionY"] as? CGFloat {
                switch  brushState{
                case "Began":
                    self.renderingBoardArea.drawWhenTouchBegins(x: x, y: y)
                case "Moved":
                    self.renderingBoardArea.drawWhenTouchMoves(x: x, y: y)
                case "Ended":
                    //print("ended brush state.")
                    self.renderingBoardArea.drawWhenTouchEnds(x: x, y: y)
                default:
                    print("Unknown brush state.")
                }
            } else {
                os_log("Failed to get brush state or position.", log: OSLog.default, type: .debug)
            }
        default:
            os_log("Unknown message type.", log: OSLog.default, type: .debug)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }

}
