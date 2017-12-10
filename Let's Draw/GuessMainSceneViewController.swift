//
//  GuessMainSceneViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/25.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log

class GuessMainSceneViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var chattingInputBoxTextField: UITextField!
    @IBOutlet weak var chattingDisplayAreaTextView: UITextView!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var DrawingBoardArea: DrawingBoard!
    
    var Hint: String!
    var me: User?
    
    var isOperationQueueCancelled = false
    var queue = OperationQueue()
    
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
    }

    override func viewDidAppear(_ animated: Bool) {
        /*
         while true {
         self.sendDrawingBoard()
         sleep(1)
         }
         */
        
        // getDrawingBoardOperation
        let getDrawingBoardOperation = BlockOperation(block: {
            //print("updateChattingArea")
            while true {
                if self.isOperationQueueCancelled {
                    break
                }
                
                self.getDrawingBoard()
                sleep(1)
            }
        })
        getDrawingBoardOperation.completionBlock = {
            print("getDrawingBoardOperation completed.")
        }
        self.queue.addOperation(getDrawingBoardOperation)
        
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
    
    private func getDrawingBoard() {
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/getDrawingBoard?roomId=\(me!.roomId!)"
        let params = NSMutableDictionary()
        var jsonData:Data? = nil
        do {
            jsonData  = try JSONSerialization.data(withJSONObject: params, options:JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            fatalError("Wrong post params when trying to creat game room.")
        }
        
            // Use semaphore to send Synchronous request
            //let semaphore = DispatchSemaphore(value: 0)
            
        ServerConnectionDelegator.anotherHttpPost(urlPath: urlPath, httpBody: jsonData!) {
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                if let ok = data {
                    print("image data: ")
                    print(ok)
                    let imageData = UIImage(data: ok)
                    OperationQueue.main.addOperation {
                        self.DrawingBoardArea.image = imageData
                    }
                }
                    
            }
            
            //semaphore.signal()
        }
            //_ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
    }

}
