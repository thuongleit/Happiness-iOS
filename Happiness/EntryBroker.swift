//
//  EntryBroker.swift
//  Happiness
//
//  Created by Dylan Miller on 12/1/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

// Manages Entry creation, updating, and deletion.
class EntryBroker {
    
    static var shared = EntryBroker()
    
    var currentViewController: UIViewController?

    let errorString = "Happiness monster hugged our server just a little too hard..."

    // Create a new entry based on the specified parameters.
    func createEntry(text: String, images: [UIImage]?, happinessLevel: Int?, placemark: String?, location: Location?) {
        
        // Create a temporary "local" entry so that the user will immediately
        // see the entry they created. This "local" entry will receive special
        // treatment (e.g., no editing, no deleting, no pull to refresh).
        let localEntry = Entry(text: text, images: images, happinessLevel: happinessLevel, placemark: placemark, createdDate: Date())
        NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.newEntryNotification.notification, object: localEntry)

        HappinessService.sharedInstance.create(
            text: text,
            images: images,
            happinessLevel: happinessLevel,
            placemark: placemark,
            location: location,
            success: { (newEntry: Entry) in
                
                // Success, replace the temporary "local" entry with the new entry.
                let notificationObject = ReplaceEntryNotificationObject(entryId: localEntry.id!, replacementEntry: newEntry, useFadeAnimation: false)
                NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.replaceEntryNotification.notification, object: notificationObject)
            },
            failure: { (error: Error) in
                
                let alertController = UIAlertController(title: "Error saving entry", message:
                    self.errorString, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                    
                    // Failure, delete the temporary "local" entry.
                    NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.deleteEntryNotification.notification, object: localEntry)
                }))
                alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                    
                    self.createEntry(text: text, images: images, happinessLevel: happinessLevel, placemark: placemark, location: location)
                }))
                self.currentViewController?.present(alertController, animated: true, completion: nil)
            }
        )
    }
    
    // Update the specified entry based on the specified parameters.
    func updateEntry(originalEntry: Entry, text: String, images: [UIImage]?, happinessLevel: Int?, placemark: String?, location: Location?) {
        
        // Replace the original entry with a temporary "local" entry, so that
        // the user will immediately see the changes.
        let localEntry = Entry(text: text, images: images, happinessLevel: happinessLevel, placemark: placemark, createdDate: originalEntry.createdDate)
        let notificationObject = ReplaceEntryNotificationObject(entryId: originalEntry.id!, replacementEntry: localEntry, useFadeAnimation: false)
        NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.replaceEntryNotification.notification, object: notificationObject)

        HappinessService.sharedInstance.update(
            entryId: originalEntry.id!,
            text: text,
            images: images,
            happinessLevel: happinessLevel,
            placemark: placemark,
            location: location,
            success: { (updatedEntry: Entry) in
                
                // Success, replace the temporary "local" entry with the updated entry.
                let notificationObject = ReplaceEntryNotificationObject(entryId: localEntry.id!, replacementEntry: updatedEntry, useFadeAnimation: false)
                NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.replaceEntryNotification.notification, object: notificationObject)
            },
            failure: { (error: Error) in
                
                let alertController = UIAlertController(title: "Error saving entry", message:
                    self.errorString, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                    
                    // Failure, replace the temporary "local" entry with the original entry.
                    let notificationObject = ReplaceEntryNotificationObject(entryId: localEntry.id!, replacementEntry: originalEntry, useFadeAnimation: false)
                    NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.replaceEntryNotification.notification, object: notificationObject)
                }))
                alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                    
                    self.updateEntry(originalEntry: originalEntry, text: text, images: images, happinessLevel: happinessLevel, placemark: placemark, location: location)
                }))
                self.currentViewController?.present(alertController, animated: true, completion: nil)
            }
        )
    }
    
    // Delete the specified entry.
    func deleteEntry(entry: Entry) {
        
        // Mark this entry for deletion to indicate this entry is currently in
        // the process of being deleted, replacing the current entry with the
        // marked entry, so that the user will immediately see the entry
        // disappear.
        entry.markForDelete(true)
        let notificationObject = ReplaceEntryNotificationObject(entryId: entry.id!, replacementEntry: entry, useFadeAnimation: true)
        NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.replaceEntryNotification.notification, object: notificationObject)

        
        HappinessService.sharedInstance.delete(
            entry: entry,
            success: { () in
                
                // Success, delete the entry.
                NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.deleteEntryNotification.notification, object: entry)
            },
            failure: { (Error) in
                
                let alertController = UIAlertController(title: "Error deleting entry", message:
                    self.errorString, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                    
                    // Failure, unmark this entry for deletion so that it
                    // appears again.
                    entry.markForDelete(false)
                    let notificationObject = ReplaceEntryNotificationObject(entryId: entry.id!, replacementEntry: entry, useFadeAnimation: true)
                    NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.replaceEntryNotification.notification, object: notificationObject)
                }))
                alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                    
                    self.deleteEntry(entry: entry)
                }))
                self.currentViewController?.present(alertController, animated: true, completion: nil)
            }
        )
    }
}
