//
//  SignupViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/12/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginSignupViewController: UIViewController, UITextFieldDelegate {
    
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
        
        if (isLoginFlow()) {
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
        
        let tapBackground = UITapGestureRecognizer()
        tapBackground.numberOfTapsRequired = 1
        tapBackground.addTarget(self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapBackground)
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
        emailTextField.keyboardType = .emailAddress
        passwordTextField.isSecureTextEntry = true
        confirmTextField.isSecureTextEntry = true
        
        // delegate
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
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
        
        if (isSignupFlow()) {
            if nameTextField.text?.characters.count == 0 {
                UIConstants.presentError(message: "Please enter your name", inView: self.view)
                return
            }
        }
        
        if (!isValidEmail(testStr: emailTextField.text!)) {
            UIConstants.presentError(message: "Please enter a valid e-mail address", inView: self.view)
            return
        }
        
        if passwordTextField.text?.characters.count == 0 {
            UIConstants.presentError(message: "Please enter a password", inView: self.view)
            return
        }
        
        if (isSignupFlow()) {
            if passwordTextField.text != confirmTextField.text {
                UIConstants.presentError(message: "The passwords you typed do not match", inView: self.view)
                return
            }
            
            if (profileImageView.image == nil) {
                UIConstants.presentError(message: "Please upload a profile image", inView: self.view)
                return
            }
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        if (isLoginFlow()) {
            
            HappinessService.sharedInstance.login(email: emailTextField.text!, password: passwordTextField.text!, success: { (user: User) in
                MBProgressHUD.hide(for: self.view, animated: true)
                print("log in success with name \(user.name)")
                NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.didLogin.notification, object: nil)
            }, failure: { (error: Error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                UIConstants.presentError(message: "Incorrect email and password.", inView: self.view)
                print("login fail with error: \(error)")
            })
        } else {
            
            HappinessService.sharedInstance.signup(email: emailTextField.text!, password: passwordTextField.text!, name: nameTextField.text!, profileImage: nil,  success: { (user: User) in
                MBProgressHUD.hide(for: self.view, animated: true)
                print("sign up success with name \(user.name)")
                NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.didLogin.notification, object: nil)

            }, failure: { (error: Error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                print("sign up fail with error: \(error)")
            })
        }
    }
    
    func dismissKeyboard() {
        for textField in [nameTextField, emailTextField, passwordTextField, confirmTextField] {
            if (textField?.isFirstResponder)! {
                textField?.resignFirstResponder()
            }
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isSignupFlow() -> Bool {
        return isSignup
    }
    
    func isLoginFlow() -> Bool {
        return !isSignup
    }
    
    // MARK: - Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
