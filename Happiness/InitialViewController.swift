//
//  InitialViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var signupButton: UIButton!

    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.titleLabel?.font = UIFont(name: UIConstants.textFontName, size: 16)
        signupButton.setTitleColor(UIConstants.secondaryThemeColor, for: .normal)
        signupButton.backgroundColor = UIConstants.primaryThemeColor
        signupButton.layer.cornerRadius = 3
        signupButton.layer.masksToBounds = true
        
        loginButton.setTitle("Already Have an Account?", for: .normal)
        loginButton.titleLabel?.font = UIFont(name: UIConstants.textFontName, size: 16)
        loginButton.setTitleColor(UIConstants.primaryThemeColor, for: .normal)
        loginButton.backgroundColor = UIConstants.secondaryThemeColor
        loginButton.layer.cornerRadius = 3
        loginButton.layer.masksToBounds = true
        
        signupButton.addTarget(self, action: #selector(onSignup), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
    }
    
    func onSignup() {
        let signupViewController = LoginSignupViewController(nibName: "LoginSignupViewController", bundle: nil)
        signupViewController.isSignup = true
        self.navigationController?.pushViewController(signupViewController, animated: true)
    }
    
    func onLogin() {
        let loginViewController = LoginSignupViewController(nibName: "LoginSignupViewController", bundle: nil)
        loginViewController.isSignup = false
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }


    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
