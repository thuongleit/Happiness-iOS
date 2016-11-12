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
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loginSignupButton: UIButton!
    
    
    var isSignup: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!isSignup) {
            nameView.isHidden = true
            loginSignupButton.setTitle("Log In", for: .normal)
        }
        
        setupContainerView()
        setupTextLabel()
        setupTextField()
        setupButton()
        
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        loginSignupButton.addTarget(self, action: #selector(onLoginSignup), for: .touchUpInside)
    }
    
    func setupContainerView() {
        for view in [nameView, emailView, passwordView] {
            UIConstants.setupLoginSignupContainerView(view: view!)
        }
    }
    
    func setupTextLabel() {
        for textlabel in [nameLabel, emailLabel, passwordLabel] {
            textlabel?.textColor = UIConstants.secondaryThemeColor
            textlabel?.font = UIFont(name: UIConstants.textFontName, size: 17)
        }
    }
    
    func setupTextField() {
        UIConstants.setupLoginSignupTextField(textField: nameTextField, withPlaceholder: "Name")
        UIConstants.setupLoginSignupTextField(textField: emailTextField, withPlaceholder: "Email")
        UIConstants.setupLoginSignupTextField(textField: passwordTextField, withPlaceholder: "Password")
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
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
