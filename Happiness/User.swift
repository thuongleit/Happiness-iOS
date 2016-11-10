//
//  User.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id: Int?
    var name: String?
    var email: String?
    var profileImageUrl: URL?
    var entries: [Entry]?
    var createdDate: Date?
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
    }

}
