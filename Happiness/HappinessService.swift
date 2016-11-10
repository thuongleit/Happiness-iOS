//
//  HappinessService.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class HappinessService: NSObject {

    static var sharedInstance = HappinessService()
    
    func login(email: String, password: String, success: @escaping (_ user: User) -> (), failure: @escaping (Error) -> ()) {
        
    }
    
    func signup(email: String, password: String, name: String, success: @escaping (_ user: User) -> (), failure: @escaping (Error) -> ()) {
     
    }
    
    func create(entry: Entry, images: [UIImage]?, success: @escaping (_ entry: Entry) -> (), failure: @escaping (Error) -> ()) {
    
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
