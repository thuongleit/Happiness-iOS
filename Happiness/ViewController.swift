//
//  ViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/1/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

class ViewController: UIViewController {
    
    
    @IBOutlet weak var alreadyAUserSwitch: UISwitch!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var entryPFImageView: PFImageView!
    @IBOutlet weak var entryLabel: UILabel!
    
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
        HappinessService.sharedInstance.signup(email: emailField.text!, password: passwordField.text!, name: nameTextField.text!, success: {(user: User) in
            print(user.name!)
        }, failure: {(error: Error) in
            print(error.localizedDescription)
        })
    }
    
    @IBAction func onCreateEntry(_ sender: Any) {
        
        let str = "test entry"
        let img = UIImage(named: "placeholder")
        let loc = Location.createLocationObject(locName: "Google West Campus 2", locLat: 37.424219, locLong: -122.092481)
        
       
        HappinessService.sharedInstance.create(text: str, images: [img!], happinessLevel: HappinessLevel.excited.rawValue, location: loc,  success: {(entry: Entry) in
            self.entryLabel.attributedText = NSAttributedString.init(string: entry.text!)
            
            self.entryPFImageView.file = entry.media
            self.entryPFImageView.loadInBackground()
            
        }, failure: {(error: Error) in
            print(error.localizedDescription)
        })
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

