//
//  ViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/1/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var alreadyAUserSwitch: UISwitch!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    
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
            emailField.isHidden = true
        }
        else{
            loginButton.isHidden = true
            signupButton.isHidden = false
            emailField.isHidden = false
        }

    }
    
    @IBAction func onLogin(_ sender: Any) {
        
        HappinessService.sharedInstance.login(username: usernameField.text!, password: passwordField.text!, success: {(user: User) in
            print(user.name!)
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    
    @IBAction func onSignup(_ sender: Any) {
        
        HappinessService.sharedInstance.signup(username: usernameField.text!, password: passwordField.text!, email: emailField.text!, success: {(user: User) in
            print(user.name!)
        }, failure: {(error: Error) in
            print(error.localizedDescription)
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

