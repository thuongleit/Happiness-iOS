//
//  SignupViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/12/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class LoginSignupViewController: UIViewController {
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var confirmTextField: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loginSignupButton: UIButton!
    
    @IBOutlet weak var buttonsTopConstraint: NSLayoutConstraint!
    
    var isSignup: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!isSignup) {
            nameView.isHidden = true
            loginSignupButton.setTitle("Log In", for: .normal)
            confirmView.isHidden = true
            buttonsTopConstraint.constant = buttonsTopConstraint.constant - confirmView.bounds.height
        }
        
        setupContainerView()
        setupTextLabel()
        setupTextField()
        setupButton()
        
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        loginSignupButton.addTarget(self, action: #selector(onLoginSignup), for: .touchUpInside)
    }
    
    func setupContainerView() {
        for view in [nameView, emailView, passwordView, confirmView] {
            UIConstants.setupLoginSignupContainerView(view: view!)
        }
    }
    
    func setupTextLabel() {
        for textlabel in [nameLabel, emailLabel, passwordLabel, confirmLabel] {
            textlabel?.textColor = UIConstants.secondaryThemeColor
            textlabel?.font = UIFont(name: UIConstants.textFontName, size: 17)
        }
    }
    
    func setupTextField() {
        UIConstants.setupLoginSignupTextField(textField: nameTextField, withPlaceholder: "Name")
        UIConstants.setupLoginSignupTextField(textField: emailTextField, withPlaceholder: "Email")
        UIConstants.setupLoginSignupTextField(textField: passwordTextField, withPlaceholder: "Password")
        UIConstants.setupLoginSignupTextField(textField: confirmTextField, withPlaceholder: "Confirm Password")
        passwordTextField.isSecureTextEntry = true
        confirmTextField.isSecureTextEntry = true
    }
    
    func setupButton() {
        for button in [backButton, loginSignupButton] {
            button?.titleLabel?.font = UIFont(name: UIConstants.textFontName, size: 16)
            button?.layer.cornerRadius = 5
            button?.layer.masksToBounds = true
            button?.backgroundColor = UIConstants.secondaryThemeColor
            button?.setTitleColor(UIConstants.primaryThemeColor, for: .normal)
        }
    }

    func onBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func onLoginSignup() {
        
        if (!isSignup) {
            
            HappinessService.sharedInstance.login(email: emailTextField.text!, password: passwordTextField.text!, success: { (user: User) in
                print("log in success with name \(user.name)")
                NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.didLogin.notification, object: nil)
            }, failure: { (error: Error) in
                print("login fail with error: \(error)")
            })
            
            
        } else {
            
            HappinessService.sharedInstance.signup(email: emailTextField.text!, password: passwordTextField.text!, name: nameTextField.text!, success: { (user: User) in
                print("sign up success with name \(user.name)")
                NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.didLogin.notification, object: nil)
            }, failure: { (error: Error) in
                print("sign up fail with error: \(error)")
            })
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
