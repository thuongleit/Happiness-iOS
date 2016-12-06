//
//  Congrats.swift
//  Happiness
//
//  Created by Dylan Miller on 11/25/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import Foundation

// Class which uses user defaults to track if the user has been congratulated
// this week.
class Congrats {
    
    static var shared = Congrats()

    private let congratsDateKey = "congratsDate"
    private var congratulatedThisWeek : Bool?
    private var didLogoutObserver: NSObjectProtocol?
    
    init() {
        
        // Reset congrats date when user logs out.
        didLogoutObserver = NotificationCenter.default.addObserver(
            forName: AppDelegate.GlobalEventEnum.didLogout.notification,
            object: nil,
            queue: OperationQueue.main)
        { [weak self] (notification: Notification) in
            
            if let _self = self {
                
                _self.congratulatedThisWeek = nil
                UserDefaults.standard.removeObject(forKey: Congrats.shared.congratsDateKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    deinit {

        // Remove all of this object's observers. For block-based observers,
        // we need a separate removeObserver(observer:) call for each observer.
        if let didLogoutObserver = didLogoutObserver {

            NotificationCenter.default.removeObserver(didLogoutObserver)
        }
    }
    
    // If the user has not been congratulated this week, sets user defaults
    // congrats date to today and returns true to indicate that a congrats
    // indication should be displayed to the user. If the user has been
    // congratulated this week, returns false to indicate that a congrats
    // indication should not be displayed to the user.
    func congratulateShouldDisplayCongrats() -> Bool {
        
        if congratulatedThisWeek == nil {
            
            congratulatedThisWeek = false
            if let congratsDate = UserDefaults.standard.object(forKey: congratsDateKey) as? Date {
                
                let (congratsWeek, congratsYear) = UIConstants.getWeekYear(date: congratsDate)
                let (thisWeek, thisYear) = UIConstants.getWeekYear(date: Date())
                if congratsYear == thisYear && congratsWeek == thisWeek {
                    
                    congratulatedThisWeek = true
                }
            }
        }
        
        let shouldDisplayCongrats: Bool
        if congratulatedThisWeek! == false {
            
            shouldDisplayCongrats = true
            
            congratulatedThisWeek = true
            UserDefaults.standard.set(Date(), forKey: congratsDateKey)
            UserDefaults.standard.synchronize()
        }
        else {
            
            shouldDisplayCongrats = false
        }
        
        return shouldDisplayCongrats
    }
}
