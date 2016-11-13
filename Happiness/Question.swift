//
//  Question.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class Question: NSObject {
    
    var id: String?
    var text: String?
    
    init(questionObject: AnyObject) {
        id = questionObject.object(forKey: "objectId") as? String
        text = questionObject.object(forKey: "text") as? String
    }
}
