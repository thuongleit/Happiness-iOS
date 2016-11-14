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
    case angry // 0-1
    case bothered // 2- 3
    case sad     // 4 -5
    case happy  //6-7
    case excited //8-9
    case superExcited //10
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
                let happinessLevelValue = entryObject.value(forKey: "happinessLevel") as? Int
                happinessLevel = Entry.getHappinessLevel(happinessLevelInt: happinessLevelValue!)
            }
        }
    }
    
    // Creates an Entry with current date and current question.
    override init() {
        // Set current date
        createdDate = Date()
        // Set current question
        question = QuestionsList.getCurrentQuestion()
    }
    
    class func getHappinessLevel(happinessLevelInt: Int) -> HappinessLevel {
        var happyLevel = HappinessLevel.happy
        switch happinessLevelInt {
        case 0:
            happyLevel = HappinessLevel.angry
        case 1:
            happyLevel = HappinessLevel.bothered
        case 2:
            happyLevel = HappinessLevel.sad
        case 3:
            happyLevel = HappinessLevel.happy
        case 4:
            happyLevel = HappinessLevel.excited
        case 5:
            happyLevel = HappinessLevel.superExcited
        default:
            happyLevel = HappinessLevel.happy
        }
        return happyLevel
    }
    
    class func getHappinessLevelInt(happinessLevel: HappinessLevel) -> Int {
        switch happinessLevel {
        case .angry:
            return 0
        case .bothered:
            return 1
        case .sad:
            return 2
        case .happy:
            return 3
        case .excited:
            return 4
        case .superExcited:
            return 5
        default:
            return 3
        }
        return 3
    }
}
