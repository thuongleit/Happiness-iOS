//
//  ViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/1/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
//import ParseUI
import AFNetworking
import AVFoundation
import CoreVideo
import CoreGraphics

class ViewController: UIViewController {
    
    @IBOutlet weak var alreadyAUserSwitch: UISwitch!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    
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
        HappinessService.sharedInstance.signup(email: emailField.text!, password: passwordField.text!, name: nameTextField.text!, profileImage: nil,  success: {(user: User) in
            
            print(user.name!)
            
        }, failure: {(error: Error) in
            print(error.localizedDescription)
        })
    }
    
    
    @IBAction func onMakeVideo(_ sender: Any) {
               
        let curUser = User.currentUser
        
        if(curUser != nil){
            
            HappinessService.sharedInstance.getEntries(beforeCreatedDate: nil, success: { (entries: [Entry]) in
                
                
                let settings = RenderSettings()
                let imageAnimator = ImageAnimator(renderSettings: settings)
                imageAnimator.images = self.loadImages(nestEntries: entries)
                imageAnimator.render() {
                    print("yes")
                }
                
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
            
        }
    }

    func loadImages(nestEntries: [Entry]) -> [UIImage]{
        
        var imagesArray = [UIImage]()
        
        for entry in nestEntries {
            if(entry.media != nil){
                let urlPath = entry.media?.url
                let url = URL(string: urlPath!)
                let imgData = NSData.init(contentsOf: url!)
                let image = UIImage.init(data: imgData as! Data)
                imagesArray.append(image!)
            }
        }
        return imagesArray
    }
    
    func loadImage(imageURLPath: String) {
        var request = URLRequest(url: URL(string: imageURLPath)!)
        request.httpMethod = "POST"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            print("Entered the completionHandler")
            let image = UIImage.init(data: data!)
            
            }.resume()

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

