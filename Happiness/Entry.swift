//
//  Entry.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

enum HappinessLevel: Int {
    case sad=0
    case happy=5
    case excited=10
}

class Entry: NSObject {

    var id: Int?
    var author: User?
    var question: Question?
    var text: NSAttributedString?
    var imageUrls: [URL]?
    var location: Location?
    var createdDate: Date?
    var happinessLevel: HappinessLevel?
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
    }
    
}
