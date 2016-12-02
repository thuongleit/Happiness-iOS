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
    
    let googleMapsBaseURL = "https://maps.googleapis.com/maps/api/geocode/json?"
    let googleMapsAPIKey = "AIzaSyC0SxpBokzPt8_s-Jf6q1yzzt7WPibKHZc"
    
    // For scrolling to work correctly, getEntriesQueryLimit must be greater
    // than maxEntriesPerWeek. If we enforce a limit of maxEntriesPerWeek in
    // the UI, a situation can still occur where multiple users create entries
    // at the same time, thus exceeding maxEntriesPerWeek. To account for this,
    // we set getEntriesQueryLimit to maxEntriesPerWeek plus a padding value of
    // maxEntriesPerWeekPadding.
    static let maxEntriesPerWeek = 100
    static let maxEntriesPerWeekPadding = 20
    let getEntriesQueryLimit = maxEntriesPerWeek + maxEntriesPerWeekPadding
    
    let getNestUsersQueryLimit = 20
    
    var loginSuccess:((User) -> ())?
    var callFailure:((Error) -> ())?
    
    var createUpdateEntrySuccess:((Entry) -> ())?
    var getEntriesSuccess:(([Entry]) -> ())?
    var deleteSuccess: (() -> ())?
    var getNestUsersSuccess:(([User]) -> ())?
    
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
                query?.includeKey("nest")
                
                query?.findObjectsInBackground(block: { (objects: [PFObject]?, error:Error?) in
                    if let error = error {
                        self.callFailure!(error)
                        print(error.localizedDescription)
                    }
                    else {
                        for pfobj in objects! {
                            let curUser = User(obj: pfobj as AnyObject)
                            User.currentUser = curUser
                            self.loginSuccess!(curUser)
                        }
                    }
                })
            }
        })
    }
    
    func signup(email: String, password: String, name: String, profileImage: UIImage?, success: @escaping (_ user: User) -> (), failure: @escaping (Error) -> ()) {
        
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
            
            if let pfImage = profileImage {
                let resizedImage = resizeImage(image: pfImage, targetSize: CGSize.init(width: 600, height: 600))
                newUser["profileImage"] = getPFFileFromImage(image: resizedImage) // PFFile column type
            }
            
            newUser.signUpInBackground {
                (succeeded: Bool, error: Error?) -> Void in
                if let error = error {
                    self.callFailure!(error)
                    print(error.localizedDescription)
                } else {
                    let pfCurrentUser = PFUser.current()
                    
                    let query = PFUser.query()
                    query?.whereKey("username", equalTo: (pfCurrentUser?.username)!)
                    query?.includeKey("nest")
                    
                    query?.findObjectsInBackground(block: { (objects: [PFObject]?, error:Error?) in
                        if let error = error {
                            self.callFailure!(error)
                            print(error.localizedDescription)
                        }
                        else {
                            for pfobj in objects! {
                                let curUser = User(obj: pfobj as AnyObject)
                                User.currentUser = curUser
                                self.loginSuccess!(curUser)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func logoutUser(){
        PFUser.logOut()
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // Convert Location to be stored on server. Helper for service create() and update() methods.
    func createLocationObject(location: Location) -> [String: Any] {
        let name = location.name ?? ""
        let latitude = location.latitude ?? 0.0
        let longitude = location.longitude ?? 0.0
        let jsonLocationObj = ["name": name, "lat" : latitude, "longi" : longitude] as [String : Any]
        return jsonLocationObj
    }
    
    func create(text: String, images: [UIImage]?, happinessLevel: Int?, placemark: String?, location: Location?, success: @escaping (_ entry: Entry) -> (), failure: @escaping (Error) -> ()) {
        
        createUpdateEntrySuccess = success
        callFailure = failure
        
        let entryObj = PFObject(className: "Entry")
        
        if let images = images {
            if(images.count > 0){
                let entryImage = images[0]
                let resizedImage = resizeImage(image: entryImage, targetSize: CGSize.init(width: 600, height: 600))
                entryObj["media"] = getPFFileFromImage(image: resizedImage) // PFFile column type
                let aspectRatio = resizedImage.size.width/resizedImage.size.height
                let str = String(format: "%.2f", aspectRatio)
                entryObj["aspectRatio"] = Double(str)
            }
        }
        
        entryObj["author"] = PFUser.current() // Pointer column type that points to PFUser
        
        let curUser = User.currentUser
        let nestId = curUser?.nest?.id
        
        if let nestId = nestId {
            let nestObj = PFObject.init(className: "Nest")
            nestObj.setValue(nestId, forKey: "objectId")
            entryObj["nest"] = nestObj
        }
        
        entryObj["text"] = text
        entryObj["happinessLevel"] = happinessLevel
        if let placemark = placemark {
            entryObj["placemark"] = placemark
        }
        
        if let location = location {
            // Convert Location to dictionary format to be stored on server
            entryObj["location"] = createLocationObject(location: location)
        }
        
        // Save object (following function will save the object in Parse asynchronously)
        entryObj.saveInBackground { (succeeded: Bool, error: Error?) in
            if let error = error {
                self.callFailure!(error)
                print(error.localizedDescription)
            } else {
                
                let query = PFQuery(className: "Entry")
                query.includeKey("author")
                query.includeKey("nest")
                query.includeKey("author.nest")
                
                query.getObjectInBackground(withId: entryObj.objectId!, block: { (object:PFObject?, error: Error?) in
                    if error == nil && object != nil {
                        let newEntry = Entry.init(entryObject: object!)
                        NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.newEntryNotification.notification, object: newEntry)
                        self.createUpdateEntrySuccess!(newEntry)
                        
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
            if let imageData = UIImageJPEGRepresentation(image, 1.0){
                return PFFile(name: "image.jpg", data: imageData)
            }
        }
        return nil
    }
    
    func update(entry: Entry, images: [UIImage]?, location: Location?, success: @escaping (_ entry: Entry) -> (), failure: @escaping (Error) -> ()) {
        
        createUpdateEntrySuccess = success
        callFailure = failure
        
        var query = PFQuery(className:"Entry")
        
        query.getObjectInBackground(withId: entry.id!, block: { (entryObj: PFObject?, error: Error?) in
            
            if error == nil && entryObj != nil {
                
                if((images?.count)! > 0){
                    let entryImage = images![0]
                    let resizedImage = self.resizeImage(image: entryImage, targetSize: CGSize.init(width: 600, height: 600))
                    entryObj?.setObject(self.getPFFileFromImage(image: resizedImage)! , forKey: "media") // PFFile column type
                    let aspectRatio = resizedImage.size.width/resizedImage.size.height
                    entryObj?.setObject(aspectRatio, forKey: "aspectRatio")
                }
                
                entryObj?.setObject(PFUser.current()!, forKey: "author")
                entryObj?.setObject(entry.text!, forKey: "text")
                if let happinessInt = entry.happinessLevel?.rawValue {
                    entryObj?.setObject(happinessInt, forKey: "happinessLevel")
                }
                
                if let location = location {
                    entryObj?.setObject(self.createLocationObject(location: location), forKey: "location")
                }
                entryObj?.setObject(entry.placemark!, forKey: "placemark")
                
                entryObj?.saveInBackground(block: { (succeded: Bool, error:Error?) in
                    if(succeded)
                    {
                        query = PFQuery(className: "Entry")
                        query.includeKey("author")
                        query.includeKey("nest")
                        query.includeKey("author.nest")
                        
                        //once saved get the object back
                        query.getObjectInBackground(withId: (entryObj?.objectId!)!, block: { (object:PFObject?, error: Error?) in
                            if error == nil && object != nil {
                                
                                let editedEntry = Entry.init(entryObject: object!)
                                NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.updateEntryNotification.notification, object: editedEntry)
                                self.createUpdateEntrySuccess!(editedEntry)
                                
                            } else {
                                self.callFailure!(error!)
                            }
                        })
                    }
                    else{
                        self.callFailure!(error!)
                    }
                })
            } else {
                self.callFailure!(error!)
            }
        })
    }
    
    func delete(entry: Entry, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        
        deleteSuccess = success
        callFailure = failure
        
        let query = PFQuery(className:"Entry")
        
        query.getObjectInBackground(withId: entry.id!, block: { (entryObj: PFObject?, error: Error?) in
            
            if error == nil && entryObj != nil {
                
                entryObj?.deleteInBackground(block: { (succeded: Bool, error: Error?) in
                    if(succeded)
                    {
                        self.deleteSuccess!()
                    }
                    else
                    {
                        self.callFailure!(error!)
                    }
                })//end of delete in background
            } else {
                self.callFailure!(error!)
            }
        })
    }
    
    // Returns all entries for current user
    func getEntries(beforeCreatedDate: Date?, success: @escaping (_ entries: [Entry]) -> (), failure: @escaping (Error) -> ()) {
        getEntriesSuccess = success
        callFailure = failure
        
        let query = PFQuery(className: "Entry")
        query.order(byDescending: "createdAt")
        
        
        let curUser = User.currentUser
        let nestId = curUser?.nest?.id
        
        if let nestId = nestId {
            let nestObj = PFObject.init(className: "Nest")
            nestObj.setValue(nestId, forKey: "objectId")
            query.whereKey("nest", equalTo: nestObj)
        }
        else{
            query.whereKey("author", equalTo: PFUser.current()!)//return only signed in user's entries
        }
        
        // If the optional parameter beforeCreatedDate was supplied for paging,
        // return entries before that date.
        if let beforeCreatedDate = beforeCreatedDate {
            
            query.whereKey("createdAt", lessThan: beforeCreatedDate)
        }
        
        query.includeKey("author")
        query.includeKey("nest")
        query.includeKey("author.nest")
        query.limit = getEntriesQueryLimit
        
        // fetch data asynchronously
        query.findObjectsInBackground { (entries: [PFObject]?, error: Error?) in
            if let error = error{
                self.callFailure!(error)
            }
            else{
                var userEntries = [Entry]()
                for pfEntryObj in entries!{
                    let entryObj = Entry.init(entryObject: pfEntryObj)
                    userEntries.append(entryObj)
                }
                self.getEntriesSuccess!(userEntries)
            }
        }
    }
    
    func getAllNestUsers(nestObjID: String?, success: @escaping (_ users: [User]) -> (), failure: @escaping (Error) -> ()){
        
        getNestUsersSuccess = success
        callFailure = failure
        
        let query = PFQuery(className: "_User")
        
        if let nestObjID = nestObjID{
            let nestObj = PFObject.init(className: "Nest")
            nestObj.setValue(nestObjID, forKey: "objectId")
            query.whereKey("nest", equalTo: nestObj)
        }
        
        query.limit = getNestUsersQueryLimit
        query.includeKey("nest")
        //query.skip = skipCount//for paging
        
        // fetch data asynchronously
        query.findObjectsInBackground(block: { (objects: [PFObject]?, error:Error?) in
            if let error = error {
                self.callFailure!(error)
                print(error.localizedDescription)
            }
            else {
                var nestUsers = [User]()
                for pfobj in objects! {
                    let curUser = User(obj: pfobj as AnyObject)
                    //print(curUser.name)
                    nestUsers.append(curUser)
                }
                self.getNestUsersSuccess!(nestUsers)
            }
        })
    }
    
    var _nestUsers: [User]?
    
    func getNestUsersForCurrentUser(success: @escaping (_ users: [User]) -> (), failure: @escaping (Error) -> ()){
        if let users = _nestUsers {
            success(users)
        } else {
            self.getAllNestUsers(nestObjID: User.currentUser?.nest?.id, success: { (users: [User]) in
                self._nestUsers = users
                success(users)
            }) { (error: Error) in
                failure(error)
            }
        }
    }
}
