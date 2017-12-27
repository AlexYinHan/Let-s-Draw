//
//  SignInViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/30.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log
import Starscream
import TextFieldEffects

class SignInViewController: UIViewController, UITextFieldDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    // MARK: Properties
    
    var me: User?
    
    @IBOutlet weak var enterGameButton: UIButton!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    
    var socket = WebSocket(url: URL(string: "ws://localhost:9090/")!, protocols: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
        enterGameButton.isEnabled = false
        
        // 设置键盘出现时页面上移
        NotificationCenter.default.addObserver(self, selector: #selector(self.kbFrameChanged(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        // navigation bar 透明
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        updateEnterGameButtonState()
    }
    // 设置键盘出现时页面上移
    @objc private func kbFrameChanged(_ notification : Notification){
        let info = notification.userInfo
        let kbRect = (info?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let offsetY = kbRect.origin.y - UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: offsetY)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // unwind navigation
    @IBAction func unwindToSignInScene(sender: UIStoryboardSegue) {
       
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "EnterGame":
            os_log("Entering game after signing in.", log: OSLog.default, type: .debug)
            guard let choosingGameRoomNavigationController = segue.destination as? UINavigationController, let choosingGameRoomViewController = choosingGameRoomNavigationController.topViewController as? ChoosingGameRoomSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // signIn and get a user ID from server
            me?.id = signIn()
            
            socket.connect()
            
            //socket.write(string: "\(self.me!.id)")
            //按理说应该在这里发送id，但是实际上这样做会使得webSocket服务器收不到这条消息
            //改为在下一场景的viewDidLoad发送
            choosingGameRoomViewController.me = self.me
            choosingGameRoomViewController.socket = self.socket
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    

    // MARK: UIImagePIckerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the iamge. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set userPhoto to display the selected image.
        userPhotoImageView.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //当用户结束编辑时（比如回车），调用这个函数， text field归还FirstResponser地位
        // Hide the keyboard.
        userNameTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //textFieldShouldReturn后调用此函数，可以获取用户输入的内容进行操作
        //mealNameLabel.text = textField.text\
        
        updateEnterGameButtonState()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 当编辑或者键盘显示在屏幕上时，调用这个函数
        //updateEnterGameButtonState()
        // Disable the save button while editing
        //enterGameButton.isEnabled = false
        //enterGameButton.backgroundColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 0.09262628425)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        enterGameButton.isEnabled = !newText.isEmpty
        if enterGameButton.isEnabled {
            enterGameButton.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.6515946062)
        } else {
            enterGameButton.backgroundColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 0.09262628425)
        }
        return true
    }
    
    // MARK: Action
    @IBAction func enterGameButtonPressed(_ sender: UIButton) {
        if let name = userNameTextField.text, let photo = userPhotoImageView.image {
            me = User(name: name, photo: photo)
        }
    }
    @IBAction func selectUserPhotoFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        //Hide the keyboard
        userNameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: Private Methods
    private func updateEnterGameButtonState() {
        // Disable the enterGame button if the userName text field is empty.
        let text = userNameTextField.text ?? ""
        enterGameButton.isEnabled = !text.isEmpty
        if enterGameButton.isEnabled {
            enterGameButton.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.6515946062)
        } else {
            enterGameButton.backgroundColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 0.09262628425)
        }
        
    }
    
    private func signIn() -> Int{
        var userId: Int?
        
        // Connect the server
        let urlPath: String = "http://localhost:3000/tasks/signIn?userName=\(self.me?.name ?? "unknown")"
        let params = NSMutableDictionary()
        
        var jsonData:Data? = nil
        do {
            jsonData  = try JSONSerialization.data(withJSONObject: params, options:JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            fatalError("Wrong post params when trying to creat game room.")
        }
        
        // Use semaphore to send Synchronous request
        let semaphore = DispatchSemaphore(value: 0)
        
        ServerConnectionDelegator.httpPost(urlPath: urlPath, httpBody: jsonData!) {
            (data, error) -> Void in
            if error != nil {
                print(error!)
            } else {
                userId = (data as! [NSDictionary])[0]["playerId"] as? Int
                print((data as! [NSDictionary])[0]["playerId"] as? Int ?? "Wrong user Id returned from server.")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        guard let resultUserId = userId else {
            fatalError("No user Id returned from server.")
        }
        
        
        return resultUserId;
    }
    
    
}
