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
    
    // Create location from server
    init(locationObject: AnyObject) {
        name = locationObject.object(forKey: "name") as? String
        latitude = locationObject.object(forKey: "lat") as? Float
        longitude = locationObject.object(forKey: "longi") as? Float
    }
    
    // Create location on client
    init(name: String?, latitude: Float, longitude: Float) {
        if let name = name {
            self.name = name
        }
        self.latitude = latitude
        self.longitude = longitude
    }

}
