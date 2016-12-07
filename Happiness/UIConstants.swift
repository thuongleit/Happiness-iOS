//
//  UIConstants.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import CoreLocation
import ParseUI

class UIConstants: NSObject {
    
    // MARK: - Colors

    // light blue
    //static let primaryThemeColor = UIColor(red: 128/255, green: 222/255, blue: 234/255, alpha: 1)
    // "Happy Mom" dark teal
    static let primaryThemeColor = UIColor(red: 63/255, green: 184/255, blue: 175/255, alpha: 1)
    
    // deep light blue
    static let primarySelectedThemeColor = UIColor(red: 77/255, green: 208/255, blue: 225/255, alpha: 1) // 107, 224, 216
    
    // pink
    static let secondaryThemeColor = UIColor(red: 248/255, green: 187/255, blue: 208/255, alpha: 1)
    
    // deep pink
    static let secondarySelectedThemeColor = UIColor(red: 244/255, green: 143/255, blue: 177/255, alpha: 1)
    
    // light purple
    static let terciaryThemeColor = UIColor(red: 215/255, green: 169/255, blue: 223/255, alpha: 1)
    
    // dark purple
    static let terciarySelectedThemeColor = UIColor(red: 186/255, green: 102/255, blue: 198/255, alpha: 1)
    
    // timeline section header: everyone completed. yellow 242,193,46
//    static let headerEveryoneCompleteColor = UIColor(red: 242/255, green: 193/255, blue: 46/255, alpha: 1)
//    static let headerEveryoneCompleteColor = UIColor(red: 86/255, green: 217/255, blue: 205/255, alpha: 1) blue
//    static let headerEveryoneCompleteColor = UIColor(red: 250/255, green: 221/255, blue: 128/255, alpha: 1) light yellow
//    static let headerEveryoneCompleteColor = UIColor(red: 248/255, green: 205/255, blue: 68/255, alpha: 1)
//    static let headerEveryoneCompleteColor = UIColor(red: 248/255, green: 211/255, blue: 109/255, alpha: 1)
    static let headerEveryoneCompleteColor = UIColor(red: 248/255, green: 214/255, blue: 99/255, alpha: 1)

    // timeline section header: # pals didn't write. orange 242,157,53
//    static let headerSomeoneIncompleteColor = UIColor(red: 242/255, green: 157/255, blue: 53/255, alpha: 1)
//    static let headerSomeoneIncompleteColor = UIColor(red: 245/255, green: 196/255, blue: 202/255, alpha: 1)
    static let headerSomeoneIncompleteColor = UIColor(red: 245/255, green: 173/255, blue: 175/255, alpha: 1)
    
    // timeline section header: you didn't write. red 242,118,73
//    static let headerYouIncompleteColor = UIColor(red: 242/255, green: 118/255, blue: 73/255, alpha: 1)
    static let headerYouIncompleteColor = UIColor(red: 242/255, green: 112/255, blue: 131/255, alpha: 1)
    
    // timeline white
    static let textLightColor = UIColor(red: 251/255, green: 248/255, blue: 244/255, alpha: 1)

    // white
    static let whiteColor = UIColor.white
    
    // light gray
    static let lightGrayColor = UIColor(red: 224/255, green: 226/255, blue: 226/255, alpha: 1)
    
    // dark gray
    static let darkGrayColor = UIColor(red: 57/255, green: 59/255, blue: 59/255, alpha: 1)
    
    // black
    static let blackColor = UIColor.black
    
    // emoji yellow
    static let emojiYellowColor = UIColor(red: 249/255, green: 206/255, blue: 50/255, alpha: 1)

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
    
    // Turns an image into grayscale colors.
    static func convertToGrayScale(image: UIImage) -> UIImage {
        let imageRect:CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        
        return newImage
    }
    
    // Turns an image into grayscale colors. Slightly different shades of gray.
    static func convertToGrayScale2(image: UIImage) -> UIImage {
        let filter: CIFilter = CIFilter(name: "CIPhotoEffectMono")!
        filter.setDefaults()
        filter.setValue(CoreImage.CIImage(image: image)!, forKey: kCIInputImageKey)
        
        return UIImage(cgImage: CIContext(options:nil).createCGImage(filter.outputImage!, from: filter.outputImage!.extent)!)
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
        
        errorBanner.backgroundColor = terciarySelectedThemeColor
        
        errorMessage.text = message
        errorMessage.textColor = textLightColor
        errorMessage.font = UIFont(name: textFontName, size: 16)
        errorMessage.textAlignment = .center
        
        errorBanner.addSubview(errorMessage)
        view.addSubview(errorBanner)
        
        UIView.animate(withDuration: 2, animations: {
            
            errorBanner.center.y = errorBanner.center.y + errorBannerHeight
            
        }, completion: {(value: Bool) in
            
            UIView.animate(withDuration: 1, delay: 4, options: [], animations: {
                
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
    
    static func fadeInImage(imageView: UIImageView, image: UIImage, withDuration: TimeInterval) {
        
        UIView.animate(
            withDuration:  imageView.image != nil ? (withDuration / 2.0) : 0.0,
            animations: {
                
                imageView.alpha = 0.0
            },
            completion: { (Bool) in
                
                UIView.animate(
                    withDuration: withDuration / 2.0,
                    animations: {
                        
                        imageView.image = image
                        imageView.alpha = 1.0
                    }
                )
            }
        )
    }
    
    static func fadeInParseImage(imageView: UIImageView, imageFile: PFFile, withDuration: TimeInterval) {
        
        imageFile.getDataInBackground { (data: Data?, error: Error?) in
            
            if error == nil, let data = data, let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    
                    fadeInImage(imageView: imageView, image: image, withDuration: withDuration)
                }
            }
        }
    }

    static func setRoundCornersForAspectFit(imageView: UIImageView, radius: CGFloat)
    {
        if let image = imageView.image {
            
            let boundsScale = imageView.bounds.size.width / imageView.bounds.size.height
            let imageScale = image.size.width / image.size.height
            var drawingRect = imageView.bounds
            if boundsScale > imageScale {
                
                drawingRect.size.width =  drawingRect.size.height * imageScale
                drawingRect.origin.x = (imageView.bounds.size.width - drawingRect.size.width) / 2
            }
            else {
                
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (imageView.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            imageView.layer.mask = mask
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
    
    //apple maps API
    static func getAreaOfInterest(location: CLLocation, completion: @escaping (_ areaOfInterest: String?, _ error: Error?) -> ()) {
        
        var placeOfInterest:String?
        let mapCompletion = completion
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            
            if (error != nil) {
                print("ERROR:" + (error?.localizedDescription)!)
                mapCompletion(nil, error)
            }
            
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])! as CLPlacemark
                if(pm.areasOfInterest != nil){
                    let areaOfInterest = pm.areasOfInterest as [String]?
                    if ((areaOfInterest?.count)! > 0){
                        placeOfInterest = areaOfInterest?[0]
                    }
                }
                else{
                    placeOfInterest = "\(pm.locality!), \(pm.administrativeArea!)"
                }
            }
            mapCompletion(placeOfInterest!, nil)
        })

    }
    
    
    // google maps API
    static func getAddressForLatLng(latitude: Float, longitude: Float) -> String? {
        var address:String?
        let url = NSURL(string: "\(HappinessService.sharedInstance.googleMapsBaseURL)latlng=\(latitude),\(longitude)&key=\(HappinessService.sharedInstance.googleMapsAPIKey)")
        var city = ""
        var state = ""
        
        let data = NSData(contentsOf: url! as URL)
        if let data = data  {
            let json = try! JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray, result.count > 0 {
                if let addressArray = result[0] as? NSDictionary {
                    address = addressArray["formatted_address"] as? String
                    if let addressComponents = addressArray["address_components"] as? NSArray {
                       
                        if let cityArray = addressComponents[2] as? NSDictionary{
                           city = cityArray["long_name"] as! String
                        }
                        
                        if let stateArray = addressComponents[4] as? NSDictionary{
                            state = stateArray["short_name"] as! String
                        }
                        
                        address = "\(city), \(state)"
                    }
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
    
    // Return the week and year of the specified date.
    static func getWeekYear(date: Date?) -> (Int, Int) {
        
        let week: Int
        let year: Int
        if let date = date {
            
            week = Calendar.current.component(.weekOfYear, from: date)
            year = Calendar.current.component(.yearForWeekOfYear, from: date)
        }
        else {
            
            week = 0
            year = 0
        }
        
        return (week, year)
    }

    class CellReuseIdentifier {
        static let timelineHeaderCell = "TimelineHeaderCell"
        static let timelineCell = "TimelineCell"
        static let viewEntryCell = "ViewEntryCell"
    }
    
    class ClassName {
        static let timelineTableHeaderViewCellXib = "TimelineHeaderView"
        static let timelineTableViewCellXib = "TimelineTableViewCell"
        static let viewEntryTableViewCellXib = "ViewEntryTableViewCell"
    }
    
    class ImageName {
        static let composeButton = "compose-22"
        static let settingsButton = "settings-22"
        static let saveButton = "save-22"
        static let cancelButton = "cancel-22"
        static let backButton = "back-22"
        static let confettiHappy = "happy-20"
        static let confettiReallyHappy = "really_happy-20"
        static let confettiHeart = "heartRed"
        static let reallyHappy = "really_happy"
    }
}

