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

    // light blue
    static let primaryThemeColor = UIColor(red: 117/255, green: 201/255, blue: 177/255, alpha: 1)
    // deep light blue
    static let primarySelectedThemeColor = UIColor(red: 117/255, green: 201/255, blue: 177/255, alpha: 1)

    
    // pink
    static let secondaryThemeColor = UIColor(red: 255/255, green: 128/255, blue: 117/255, alpha: 1)
    // deep pink
    static let secondarySelectedThemeColor = UIColor(red: 226/255, green: 38/255, blue: 77/255, alpha: 1)
    
    // white
    static let textLightColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)


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
    
    // MARK: - Views
    static func presentError(message: String, inView view: UIView) {
        
        view.layer.removeAllAnimations()
        
        let errorBanner = UIView()
        let errorMessage = UILabel()
        let errorBannerWidth = UIScreen.main.bounds.width
        let errorBannerHeight: CGFloat = 60
        errorBanner.frame = CGRect(x: 0, y: -errorBannerHeight, width: errorBannerWidth, height: errorBannerHeight)
        errorMessage.frame = errorBanner.bounds
        
        errorBanner.backgroundColor = primaryThemeColor
        
        errorMessage.text = message
        errorMessage.textColor = secondaryThemeColor
        errorMessage.font = UIFont(name: textFontName, size: 16)
        errorMessage.textAlignment = .center
        
        errorBanner.addSubview(errorMessage)
        view.addSubview(errorBanner)
        
        UIView.animate(withDuration: 1, animations: {
            
            errorBanner.center.y = errorBanner.center.y + errorBannerHeight
            
        }, completion: {(value: Bool) in
            
            UIView.animate(withDuration: 1, delay: 2, options: [], animations: {
                
                errorBanner.center.y = errorBanner.center.y - errorBannerHeight
                
            }, completion: { (value: Bool) in
                
                errorBanner.removeFromSuperview()
            })
        })
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
    
    // MARK: - Date
    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d y" // Nov 12, 2016  "EEE MMM d HH:mm:ss Z y"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    // MARK: - Location
    static func locationString(from location: Location) -> String {
        if let name = location.name {
            if name.characters.count > 0 {
                return name
            }
        }
        
        if (location.latitude != nil), (location.longitude != nil) {
            let address = UIConstants.getAddressForLatLng(latitude: location.latitude!, longitude: location.longitude!)
            
            if (address != nil) {
                return address!
            }
            else{
                return "\(location.latitude!), \(location.longitude!)"
            }
        }
        return ""
    }
       
    static func getAddressForLatLng(latitude: Float, longitude: Float) -> String? {
        var address:String?
        let url = NSURL(string: "\(HappinessService.sharedInstance.googleMapsBaseURL)latlng=\(latitude),\(longitude)&key=\(HappinessService.sharedInstance.googleMapsAPIKey)")
        let data = NSData(contentsOf: url! as URL)
        if let data = data  {
            let json = try! JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                if let addressArray = result[0] as? NSDictionary {
                    address = addressArray["formatted_address"] as? String
                }
            }
        }
        return address
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
    
    class ImageName {
        static let composeButton = "compose-22"
    }
}
