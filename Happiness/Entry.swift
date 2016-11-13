//
//  Entry.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import Parse

enum HappinessLevel: Int {
    case sad=0
    case happy=5
    case excited=10
}

class Entry: NSObject {
    
    var id: String?
    var author: User?
    var question: Question?
    var text: String?
    var imageUrls: [URL]?
    var media:PFFile?
    var location: Location?
    var createdDate: Date?
    var happinessLevel: HappinessLevel?
    var image: UIImage?
    
    init(entryObject: AnyObject?) {
        if let entryObject = entryObject {
            id = entryObject.value(forKey: "objectId") as? String
            author = User.init(obj: entryObject.object(forKey: "author") as AnyObject)
            text = entryObject.object(forKey: "text") as? String // on db side it is only string not NSAttributedString
            createdDate = entryObject.value(forKey: "createdAt") as? Date
            
            if(entryObject.object(forKey: "question") != nil){
                question = Question.init(questionObject: entryObject.object(forKey: "question") as AnyObject)
            }
            
            if(entryObject.object(forKey: "media") != nil){
                media = entryObject.object(forKey: "media") as? PFFile
            }
            
            if(entryObject.object(forKey: "location") != nil){
                location = Location.init(locationObject: entryObject.object(forKey: "location") as AnyObject)
            }
            
            if(entryObject.value(forKey: "happinessLevel") != nil){
                happinessLevel = HappinessLevel(rawValue: (entryObject.value(forKey: "happinessLevel") as? Int)!)
            }
        }
    }
    
}
