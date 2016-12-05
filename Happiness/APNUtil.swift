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
        push.setData(data)
        
        push.sendInBackground(block: {(result, error) in
            completionBlock(result)
        })
    }
}
