//
//  Location.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class Location: NSObject {
    
    var name: String?
    var latitude: Float?
    var longitude: Float?
    
    init(locationObject: AnyObject) {
        name = locationObject.object(forKey: "name") as? String
        latitude = locationObject.object(forKey: "lat") as? Float
        longitude = locationObject.object(forKey: "longi") as? Float
    }
    
    class func createLocationObject(locName: String?, locLat: Float, locLong: Float ) -> [String: Any] {
        var lName = ""
        if let locName = locName{
            lName = locName
        }
      
        let jsonLocationObj = ["name": lName, "lat" : locLat, "longi" : locLong] as [String : Any]
        return jsonLocationObj
    }
    
}
