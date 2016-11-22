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
        let query = PFUser.query()
        query?.whereKey(emailKey, equalTo: targetEmail)
        PFPush.sendMessageToQuery(inBackground: query as! PFQuery<PFInstallation>, withMessage: message, block: { (result, error) in
            completionBlock(result)
        })
    }
    
    


}
