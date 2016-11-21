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
        
        profileImage?.getDataInBackground(block: { (fileData: Data?, error: Error?) in
            
            if(error == nil){
                aCoder.encode(fileData, forKey: "profileImage")
                  //defaults.synchronize()
            }
        })
        
        aCoder.encode(nest, forKey: "nest")
    }
    
    static var _currentUser: User?
    class var currentUser: User? {
        get {
            if(_currentUser == nil){
                let defaults = UserDefaults.standard
                
                if let userData = defaults.object(forKey: "currentUser") as? Data {
                    _currentUser = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User
                }
            }
            return _currentUser
        }
        set(user){
            _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let savedData = NSKeyedArchiver.archivedData(withRootObject: user)
                defaults.set(savedData, forKey: "currentUser")
            }
            else{
                defaults.set(nil, forKey: "currentUser")
            }
            
            defaults.synchronize()
            
        }
    }
    
}
