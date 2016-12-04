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
    var media:PFFile?
    //var location: Location?
    var createdDate: Date?
    var happinessLevel: HappinessLevel?
    var aspectRatio:Double?
    var placemark:String?//location stored as string
    
    // Indicates whether this is a temporary "local" entry which has not yet
    // been saved to the database.
    var isLocal = false
    
    // Image for a temporary "local" entry.
    var localImage: UIImage?
    
    // Indicates whether this entry is currently in the process of being deleted.
    var isLocalMarkedForDelete = false
    
    // Creates an Entry from the server data.
    init(entryObject: AnyObject?) {
        
        if let entryObject = entryObject {
            id = entryObject.value(forKey: "objectId") as? String
            author = User.init(obj: entryObject.object(forKey: "author") as AnyObject)
            text = entryObject.object(forKey: "text") as? String // on db side it is only string not NSAttributedString
            createdDate = entryObject.value(forKey: "createdAt") as? Date
            aspectRatio = entryObject.value(forKey: "aspectRatio") as? Double
            placemark = ""
            
            if let areaOfInterest = entryObject.value(forKey: "placemark") as? String {
                placemark = areaOfInterest
            }
            else {
                if(entryObject.object(forKey: "location") != nil){
                    let location = Location.init(locationObject: entryObject.object(forKey: "location") as AnyObject)
                    placemark = UIConstants.locationString(from: location)
                }
            }
            
            if(entryObject.object(forKey: "question") != nil){
                question = Question.init(questionObject: entryObject.object(forKey: "question") as AnyObject)
            }
            
            if(entryObject.object(forKey: "media") != nil){
                media = entryObject.object(forKey: "media") as? PFFile
            }
            
            if(entryObject.value(forKey: "happinessLevel") != nil){
                let happinessLevelValue = entryObject.value(forKey: "happinessLevel") as? Int
                happinessLevel = Entry.getHappinessLevel(happinessLevelInt: happinessLevelValue!)
            }
            
            isLocal = false
            localImage = nil
            isLocalMarkedForDelete = false
        }
    }
    
    // Creates a temporary "local" Entry.
    init(text: String, images: [UIImage]?, happinessLevel: Int?, placemark: String?, createdDate: Date?) {
        
        self.id = "\(Int64(arc4random()))"
        self.author = User.currentUser
        self.question = nil
        self.text = text
        self.media = nil
        self.createdDate = createdDate
        if let happinessLevel = happinessLevel {
            
            self.happinessLevel = Entry.getHappinessLevel(happinessLevelInt: happinessLevel)
        }
        else {
            
            self.happinessLevel = nil
        }
        self.placemark = placemark
        self.isLocal = true
        if let images = images, images.count > 0 {
            
            self.localImage = images[0]
            self.aspectRatio = Double(images[0].size.width / images[0].size.height)
        }
        else {
            
            self.localImage = nil
            self.aspectRatio = nil
        }
        self.isLocalMarkedForDelete = false
    }
    
    // Creates an Entry with current date and current question.
    override init() {
        // Set current date
        createdDate = Date()
        // Set current question
        question = QuestionsList.getCurrentQuestion()
    }
    
    // Mark or unmark this entry for deletion. If an entry is marked, that
    // indicates that the entry is currently in the process of being deleted.
    // Such entries are treated as temporary "local" entries so that features
    // such as pull to refresh are disabled until the deletion is completed.
    func markForDelete(_ mark: Bool) {
     
        isLocal = mark
        isLocalMarkedForDelete = mark
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
        }
    }
}
