//
//  APNUtil.swift
//  Happiness
//
//  Created by James Zhou on 11/21/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import Parse

class APNUtil: NSObject {
    
    static let emailKey = "email"
    
    // MARK: - Nudging
    static func sendNudging(targetEmail: String, withMessage message: String, completionBlock: @escaping (_ isSuccess: Bool) -> ()) {
        
        let query = PFInstallation.query()
        query?.whereKey(emailKey, equalTo: targetEmail)
        let push = PFPush()
        push.setQuery(query as! PFQuery<PFInstallation>)
        var data = [AnyHashable : Any]()
        data["sound"] = "notification.caf"
        data["alert"] = message
        data["nudge"] = true
        push.setData(data)
        
        push.sendInBackground(block: {(result, error) in
            completionBlock(result)
        })
    }
    
    // MARK: - Broadcasting congratulations
    static func sendConratulations(toNestUsers users: [User], completionBlock: @escaping(_ isSuccess: Bool) -> ()) {
        
        let message = "Congratulations! All users have completed this week's challenge!"
        
        let query = PFInstallation.query()
        
        var emailArray = [String]()
        for user in users {
            if user.email != User.currentUser?.email {
                emailArray.append(user.email!)
            }
        }
        
        query?.whereKey(emailKey, containedIn: emailArray)
        
        let push = PFPush()
        push.setQuery(query as! PFQuery<PFInstallation>)
        var data = [AnyHashable : Any]()
        data["sound"] = "notification.caf"
        data["alert"] = message
        data["nudge"] = false
        
        push.setData(data)
        
        push.sendInBackground(block: {(result, error) in
            completionBlock(result)
        })

    }
}
