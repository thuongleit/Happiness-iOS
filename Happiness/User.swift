//
//  User.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import Parse

final class User: NSObject, NSCoding {
    
    static var currentUserKey = "currentUser"
    
    var id: String?
    var name: String?
    var email: String?
    var profileImage: PFFile?
    //var entries: [Entry]?
    var createdDate: Date?
    var nest: Nest?
    
    init(obj: AnyObject) {
        id = obj.value(forKey: "objectId") as? String
        name = obj.object(forKey: "name") as? String
        email = obj.object(forKey: "email") as? String
        createdDate = obj.value(forKey: "createdAt") as? Date
        
        if(obj.object(forKey: "profileImage") != nil){
            profileImage = obj.object(forKey: "profileImage") as? PFFile
        }
        
        if(obj.object(forKey: "nest") != nil){
            nest = Nest.init(obj: obj.object(forKey: "nest") as AnyObject)
        }
    }
    
    init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "objectId") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        createdDate = aDecoder.decodeObject(forKey: "createdAt") as? Date
        
        profileImage = aDecoder.decodeObject(forKey: "profileImage") as? PFFile
        nest = aDecoder.decodeObject(forKey: "nest") as? Nest
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "objectId")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(createdDate, forKey: "createdDate")
        
        // Must use synchronous getData() rather than asynchronous
        // getDataInBackground(), since encoding must be done before this
        // function returns or else the following exception occurs:
        // "[NSKeyedArchiver encodeObject:forKey:]: archive already finished,
        // cannot encode anything more"
        do {
            let fileData = try profileImage?.getData()
            aCoder.encode(fileData, forKey: "profileImage")
        }
        catch {
        }
        
        aCoder.encode(nest, forKey: "nest")
    }
    
    static var _currentUser: User?
    class var currentUser: User? {
        get {
            if(_currentUser == nil) {
                let defaults = UserDefaults.standard
                
                if let userData = defaults.object(forKey: currentUserKey) as? Data {
                    _currentUser = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User
                }
            }
            return _currentUser
        }
        set(user){
            _currentUser = user
            
            // Do not block the main thread.
            DispatchQueue.global(qos: .background).async {
                
                let defaults = UserDefaults.standard
                
                if let user = user {
                    let savedData = NSKeyedArchiver.archivedData(withRootObject: user)
                    defaults.set(savedData, forKey: currentUserKey)
                }
                else {
                    defaults.removeObject(forKey: currentUserKey)
                }
                
                defaults.synchronize()
            }
        }
    }
}
