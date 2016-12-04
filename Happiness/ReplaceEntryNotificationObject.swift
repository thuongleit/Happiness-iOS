//
//  ReplaceEntryNotificationObject.swift
//  Happiness
//
//  Created by Dylan Miller on 12/4/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import Foundation

// Object for replaceEntryNotification. The entryId identifies which entry to
// replace, and the replacementEntry identifies the replacement entry.
class ReplaceEntryNotificationObject {
    
    var entryId: String
    var replacementEntry: Entry
    var useFadeAnimation: Bool
    
    init(entryId: String, replacementEntry: Entry, useFadeAnimation: Bool) {
        
        self.entryId = entryId
        self.replacementEntry = replacementEntry
        self.useFadeAnimation = useFadeAnimation
    }
}
