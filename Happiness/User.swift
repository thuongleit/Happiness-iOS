//
//  User.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: URL?
    var entries: [Entry]?
    var createdDate: Date?
    
    init(obj :AnyObject) {
        id = obj.value(forKey: "objectId") as? String
        name = obj.object(forKey: "name") as? String
        email = obj.object(forKey: "email") as? String
        createdDate = obj.value(forKey: "createdAt") as? Date
    }

}
