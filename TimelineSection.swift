//
//  TimelineSection.swift
//  Happiness
//
//  Created by Dylan Miller on 12/2/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

// Represents a section in a timeline table.
class TimelineSection {
    
    let week: Int
    let year: Int
    let title: String
    var entries = [Entry]()// why was it private
    private var userEntryCount = [String: Int]() // maps user IDs to entry counts
    private var _localEntriesCount = 0
    
    var localEntriesCount: Int {
        
        return _localEntriesCount
    }
    
    var rows: Int {
        
        var currentUserEntryCount = 0
        if let currentUserId = User.currentUser?.id,
            let _currentUserEntryCount = userEntryCount[currentUserId] {
            
            currentUserEntryCount = _currentUserEntryCount
        }
        
        // Only display entries for milestone if current user created an
        // entry for that milestone.
        return currentUserEntryCount > 0 ? entries.count : 0
    }
    
    init(week: Int, year: Int) {
        
        self.week = week
        self.year = year
        self.title = String(format: "Week %d, %d", week, year)
    }
    
    // Add the specified entry to the end of the entries array.
    func append(entry: Entry) {
        
        if let userId = entry.author?.id {
            
            userEntryCount[userId] = (userEntryCount[userId] ?? 0) + 1
        }
        
        if entry.isLocal {
            
            _localEntriesCount = _localEntriesCount + 1
        }
        
        entries.append(entry)
    }
    
    // Add the specified entry to the start of the entries array.
    func prepend(entry: Entry) {
        
        if let userId = entry.author?.id {
            
            userEntryCount[userId] = (userEntryCount[userId] ?? 0) + 1
        }
        
        if entry.isLocal {
            
            _localEntriesCount = _localEntriesCount + 1
        }
        
        entries.insert(entry, at: 0)
    }
    
    // Return the specified entry from the entries array.
    func get(entryAtRow atRow: Int) -> Entry {
        
        return entries[atRow]
    }
    
    // Remove the specified entry from the entries array.
    func remove(entryAtRow atRow: Int) {
        
        let entry = entries[atRow]
        if let userId = entry.author?.id {
            
            userEntryCount[userId] = (userEntryCount[userId] ?? 0) - 1
        }
        
        if entry.isLocal {
            
            _localEntriesCount = _localEntriesCount - 1
        }

        entries.remove(at: atRow)
    }
    
    
    // Remove the entry with an ID matching the specified entry, if found.
    // Return true if an entry was removed, false otherwise.
    func remove(entry: Entry) -> Bool {
        
        if let index = getRow(entryWithId: entry.id!) {
            
            remove(entryAtRow: index)
            return true
        }
        else {
            
            return false
        }
    }
    
    // Replace the the specified entry, if found. Return true if an entry was
    // updated, false otherwise.
    func replace(entryWithId entryId: String, replacementEntry: Entry) -> Bool {
        
        if let index = getRow(entryWithId: entryId) {
            
            // entries[index] and replacementEntry may or may not reference the
            // same Entry object, so we copy replacementEntry to entries[index].
            entries[index] = replacementEntry
            return true
        }
        else {
            
            return false
        }
    }
    
    // Return the row index of the entry with an ID matching the specified
    // entry, if found. Otherwise, return nil.
    func getRow(entryWithId entryId: String) -> Int? {
        
        for (entryIndex, entry) in entries.enumerated() {
            
            if entry.id == entryId {
                
                return entryIndex
            }
        }
        return nil
    }
    
    // Return the count of entries for the specified user, or nil if no
    // such user has entries.
    func getEntryCount(userWithId userId: String) -> Int? {
        
        return userEntryCount[userId]
    }
    
    // Return the count of users who have at least one entry.
    func getCountOfUsersWithEntries() -> Int {
        
        var countOfUsersWithEntries = 0
        for (_, entryCount) in userEntryCount {
            
            if entryCount > 0 {
                
                countOfUsersWithEntries = countOfUsersWithEntries + 1
            }
        }
        return countOfUsersWithEntries
    }
    
    // Returns a dictionary of user id to count of entries written for each user
    // in the current user's nest.
    func getEntryCountByUser() -> [String: Int]? {
        
        return userEntryCount
    }
}
