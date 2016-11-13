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
    
    // Creates an Entry from the server data.
    init(entryObject: AnyObject) {
        id = entryObject.value(forKey: "objectId") as? String
        author = User.init(obj: entryObject.object(forKey: "author") as AnyObject)
        if(entryObject.object(forKey: "question") != nil){
            question = Question.init(questionObject: entryObject.object(forKey: "question") as AnyObject)
        }
        text = entryObject.object(forKey: "text") as? String // on db side it is only string not NSAttributedString
        media = entryObject.object(forKey: "media") as? PFFile        
        location = Location.init(locationObject: entryObject.object(forKey: "location") as AnyObject)
        createdDate = entryObject.value(forKey: "createdAt") as? Date
        happinessLevel = HappinessLevel(rawValue: (entryObject.value(forKey: "happinessLevel") as? Int)!)
    }
    
    // Creates an Entry with current date and current question.
    override init() {
        // Set current date
        createdDate = Date()
        // Set current question
        question = QuestionsList.getCurrentQuestion()
    }
    
}
