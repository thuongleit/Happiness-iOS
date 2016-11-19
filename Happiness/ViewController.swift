//
//  ViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/1/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var alreadyAUserSwitch: UISwitch!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    

    @IBOutlet weak var profileImageFromCamera: UIImageView!
    @IBOutlet weak var profilePFImageView: PFImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        signupButton.layer.cornerRadius = 5
        setUpFieldsVisibility()
    }
    
    @IBAction func onAlreadyAUserChange(_ sender: Any) {
        setUpFieldsVisibility()
    }

    func setUpFieldsVisibility(){
        if(alreadyAUserSwitch.isOn)
        {
            loginButton.isHidden = false
            signupButton.isHidden = true
            nameTextField.isHidden = true
        }
        else{
            loginButton.isHidden = true
            signupButton.isHidden = false
            nameTextField.isHidden = false
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        HappinessService.sharedInstance.login(email: emailField.text!, password: passwordField.text!, success: {(user: User) in
            print(user.name!)
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    @IBAction func onSignup(_ sender: Any) {
        HappinessService.sharedInstance.signup(email: emailField.text!, password: passwordField.text!, name: nameTextField.text!, profileImage: profileImageFromCamera.image,  success: {(user: User) in
            print(user.name!)
            
            if let photoFile = user.profileImage {
                self.profilePFImageView.file = photoFile
                self.profilePFImageView.loadInBackground()
                self.profilePFImageView.clipsToBounds = true
            } else {
                self.profilePFImageView.image = nil
            }

            
        }, failure: {(error: Error) in
            print(error.localizedDescription)
        })
    }
    
    @IBAction func onProfileImageUpload(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileImageFromCamera.contentMode = .scaleAspectFit
        profileImageFromCamera.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

