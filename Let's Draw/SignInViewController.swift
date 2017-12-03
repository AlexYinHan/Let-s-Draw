//
//  SignInViewController.swift
//  Let's Draw
//
//  Created by apple on 2017/11/30.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import os.log

class SignInViewController: UIViewController, UITextFieldDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    // MARK: Properties
    
    var me: Player?
    
    @IBOutlet weak var enterGameButton: UIButton!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTextField.delegate = self
        enterGameButton.isEnabled = false
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "EnterGame":
            os_log("Entering game after signing in.", log: OSLog.default, type: .debug)
            guard let choosingGameRoomViewController = segue.destination as? ChoosingGameRoomSceneViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            choosingGameRoomViewController.me = self.me
            
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
        // Disable the save button while editing
        enterGameButton.isEnabled = false
    }
    
    // MARK: Action
    @IBAction func enterGameButtonPressed(_ sender: UIButton) {
        if let name = userNameTextField.text, let photo = userPhotoImageView.image {
            me = Player(name: name, photo: photo)
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
    }
}
