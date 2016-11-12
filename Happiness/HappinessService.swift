//
//  HappinessService.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import Parse

class HappinessService: NSObject {
    
    static var sharedInstance = HappinessService()
    
    let parseApplicationID = "4Lp3DZTydiCTjsmftoTctwTo0Edb1hTVe4wgqxOM"
    let parseClientKey = "sENDA3tgrescOEbnZywnmJ5lFcoFgVLWd3Ka26tQ"
    
    var loginSuccess:((User) -> ())?
    var callFailure:((Error) -> ())?
    
    var createEntrySuccess:((Entry) -> ())?
    var getEntriesSuccess:(([Entry]) -> ())?
    
    func login(email: String, password: String, success: @escaping (_ user: User) -> (), failure: @escaping (Error) -> ()) {
        
        loginSuccess = success
        callFailure = failure
        
        //email used as username in the app
        let username = email
        
        PFUser.logInWithUsername(inBackground: username, password: password, block: { (user: PFUser?, error: Error?) -> Void in
            if let error = error {
                self.callFailure!(error)
                print("User login failed.")
                print(error.localizedDescription)
            } else {
                print("User logged in successfully")
                
                let pfCurrentUser = PFUser.current()
                
                let query = PFUser.query() //cant query user table using PFQuery, use PFUser
                query?.whereKey("objectId", equalTo: (pfCurrentUser?.objectId)!)
                
                query?.findObjectsInBackground(block: { (objects: [PFObject]?, error:Error?) in
                    if let error = error {
                        self.callFailure!(error)
                        print(error.localizedDescription)
                    }
                    else {
                        for pfobj in objects! {
                            let curUser = User(obj: pfobj as AnyObject)
                            self.loginSuccess!(curUser)
                        }
                    }
                })
            }
        })
    }
    
    func signup(email: String, password: String, name: String, success: @escaping (_ user: User) -> (), failure: @escaping (Error) -> ()) {
        
        loginSuccess = success
        callFailure = failure
        
        //email used as username in the app
        let username = email
        
        if(username != "" && password != ""){
            let newUser = PFUser()
            
            newUser.username = username
            newUser.password = password
            newUser.email = email
            newUser.setObject(name, forKey: "name")//custom field
            
            newUser.signUpInBackground {
                (succeeded: Bool, error: Error?) -> Void in
                if let error = error {
                    self.callFailure!(error)
                    print(error.localizedDescription)
                } else {
                    let pfCurrentUser = PFUser.current()
                    
                    let query = PFUser.query()
                    query?.whereKey("username", equalTo: (pfCurrentUser?.username)!)
                    
                    query?.findObjectsInBackground(block: { (objects: [PFObject]?, error:Error?) in
                        if let error = error {
                            self.callFailure!(error)
                            print(error.localizedDescription)
                        }
                        else {
                            for pfobj in objects! {
                                let curUser = User(obj: pfobj as AnyObject)
                                self.loginSuccess!(curUser)
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    func create(text: String, images: [UIImage]?, happinessLevel: Int?, location: [String: Any]?, success: @escaping (_ entry: Entry) -> (), failure: @escaping (Error) -> ()) {
        
        createEntrySuccess = success
        callFailure = failure
        
        let entryObj = PFObject(className: "Entry")
        if((images?.count)! > 0){
            entryObj["media"] = getPFFileFromImage(image: images?[0]) // PFFile column type
        }
        entryObj["author"] = PFUser.current() // Pointer column type that points to PFUser
        entryObj["text"] = text
        entryObj["happinessLevel"] = happinessLevel
        entryObj["location"] = location
        
        // Save object (following function will save the object in Parse asynchronously)
        entryObj.saveInBackground { (succeeded: Bool, error: Error?) in
            if let error = error {
                self.callFailure!(error)
                print(error.localizedDescription)
            } else {
                
                let query = PFQuery(className: "Entry")
                query.includeKey("author")
                
                query.getObjectInBackground(withId: entryObj.objectId!, block: { (object:PFObject?, error: Error?) in
                    if error == nil && object != nil {
                        
                        self.createEntrySuccess!(Entry.init(entryObject: object!))
                        
                    } else {
                        self.callFailure!(error!)
                    }
                })
            }
        }
    }
    
    func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }
    
    func update(entry: Entry, images: [UIImage]?, success: @escaping (_ entry: Entry) -> (), failure: @escaping (Error) -> ()) {
        
    }
    
    func uploadImage(image: UIImage, success: @escaping (_ url: URL) -> (), failure: @escaping (Error) -> ()) {
    }
    
    func deleteImage(imageUrl: URL, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
    }
    
    func delete(entry: Entry, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        
    }
    
    // Returns all entries for current user
    func getEntries(success: @escaping (_ entries: [Entry]) -> (), failure: @escaping (Error) -> ()) {
        
    }
    
    // Returns all entries for current user between start and end date
    // Nil start or end dates means no date constraints
    func getEntries(startDate: Date?, endDate: Date?, success: @escaping (_ entries: [Entry]) -> (), failure: @escaping (Error) -> ()) {
        
    }
    
    // We will set up database of questions and push notifications for questions in sprint 2.
    //    func getQuestion
    
    
}
