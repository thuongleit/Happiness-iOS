//
//  UIConstants.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class UIConstants: NSObject {
    
    // MARK: - Colors
    static let primaryThemeColor = UIColor(red: 123/255, green: 104/255, blue: 238/255, alpha: 1)
    
    static let secondaryThemeColor = UIColor(red: 0/255, green: 255/255, blue: 127/255, alpha: 1)
    
    static func happinessLevelColor(_ happinessLevel: HappinessLevel) -> UIColor {
        switch happinessLevel {
        case .angry: // deep red
            return UIColor.init(colorLiteralRed: 205/255.0, green: 45/255.0, blue: 34/255.0, alpha: 1.0)
        case .bothered: // light red
            return UIColor.init(colorLiteralRed: 254/255.0, green: 110/255.0, blue: 75/255.0, alpha: 1.0)
        case .sad: // light blue
            return UIColor.init(colorLiteralRed: 117/255.0, green: 201/255.0, blue: 177/255.0, alpha: 1.0)
        case .happy: // yellow
            return UIColor.init(colorLiteralRed: 255/255.0, green: 212/255.0, blue: 84/255.0, alpha: 1.0)
        case .excited: // turquoise
            return UIColor.init(colorLiteralRed: 123/255.0, green: 209/255.0, blue: 134/255.0, alpha: 1.0)
        case .superExcited: // bright turquiose
            return UIColor.init(colorLiteralRed: 25/255.0, green: 207/255.0, blue: 134/255.0, alpha: 1.0)
        }
    }

    // MARK: - Images

    static func happinessLevelImage(_ happinessLevel: HappinessLevel) -> UIImage {
        switch happinessLevel {
        case .angry:
            return UIImage(named: "angry")!
        case .bothered:
            return UIImage(named: "bothered")!
        case .sad:
            return UIImage(named: "sad")!
        case .happy:
            return UIImage(named: "happy")!
        case .excited:
            return UIImage(named: "really_happy")!
        case .superExcited:
            return UIImage(named: "super_excited")!
        }
    }

    // MARK: - Text
    static let textFontName = "Avenir-Medium"
    
    // MARK: - Login/Signup
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
    
    class CellReuseIdentifier {
        static let timelineCell = "TimelineCell"
    }
    
    class ClassName {
        static let timelineTableViewCellXib = "TimelineTableViewCell"
    }
    

}
