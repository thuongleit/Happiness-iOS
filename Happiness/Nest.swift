//
//  Nest.swift
//  Happiness
//
//  Created by Deeksha Prabhakar on 11/17/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import Parse

class Nest: NSObject, NSCoding {
    
    var id: String?
    var name: String?
    
    init(obj: AnyObject) {
        id = obj.value(forKey: "objectId") as? String
        name = obj.value(forKey: "name") as? String
    }
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "objectId") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "objectId")
        aCoder.encode(name, forKey: "name")
    }
}
