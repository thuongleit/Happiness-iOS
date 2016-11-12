//
//  UIConstants.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class UIConstants: NSObject {
    
    // MARK : - Colors
    static let primaryThemeColor = UIColor(red: 123/255, green: 104/255, blue: 238/255, alpha: 1)
    
    static let secondaryThemeColor = UIColor(red: 0/255, green: 255/255, blue: 127/255, alpha: 1)
    
    // MARK : - Text
    static let textFontName = "Avenir-Medium"
    
    // MARK : - Login/Signup
    static func setupLoginSignupContainerView(view: UIView) {
        view.backgroundColor = UIConstants.primaryThemeColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    
    static func setupLoginSignupTextField(textField: UITextField, withPlaceholder placeholder: String) {
        textField.backgroundColor = UIConstants.primaryThemeColor
        textField.borderStyle = .none
        textField.tintColor = UIConstants.secondaryThemeColor
        textField.textColor = UIConstants.secondaryThemeColor
        textField.font = UIFont(name: UIConstants.textFontName, size: 17)
        textField.autocorrectionType = .no
        textField.placeholder = placeholder
    }
    
    
    // sample function
    static func getBottomTextSize() -> CGFloat {
        return 20
    }
    
    
    
    
    

}
