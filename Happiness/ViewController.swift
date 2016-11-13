//
//  ViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/1/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

class ViewController: UIViewController {
    
    
    @IBOutlet weak var alreadyAUserSwitch: UISwitch!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var entryPFImageView: PFImageView!
    @IBOutlet weak var entryLabel: UILabel!
    
    
    @IBOutlet weak var latestCreatedEntryImageView: PFImageView!
    @IBOutlet weak var latestCreatedEntryLabel: UILabel!
    var lastAddedEntry:Entry?
    
    @IBOutlet weak var lastEditedEntryImageView: PFImageView!
    
    @IBOutlet weak var lastEditedEntryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        signupButton.layer.cornerRadius = 5
        setUpFieldsVisibility()
    }
    
    @IBAction func onAlreadyAUserChange(_ sender: Any) {
        setUpFieldsVisibility()
    }

    func setUpFieldsVisibility(){
        if(alreadyAUserSwitch.isOn)
        {
            loginButton.isHidden = false
            signupButton.isHidden = true
            nameTextField.isHidden = true
        }
        else{
            loginButton.isHidden = true
            signupButton.isHidden = false
            nameTextField.isHidden = false
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        HappinessService.sharedInstance.login(email: emailField.text!, password: passwordField.text!, success: {(user: User) in
            print(user.name!)
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    
    @IBAction func onSignup(_ sender: Any) {
        HappinessService.sharedInstance.signup(email: emailField.text!, password: passwordField.text!, name: nameTextField.text!, success: {(user: User) in
            print(user.name!)
        }, failure: {(error: Error) in
            print(error.localizedDescription)
        })
    }
    
    @IBAction func onCreateEntry(_ sender: Any) {
        
        let str = "test entry"
        let img = UIImage(named: "placeholder")
        let loc = Location(name: "Google West Campus 2", latitude: 37.424219, longitude: -122.092481)
        
       
        HappinessService.sharedInstance.create(text: str, images: [img!], happinessLevel: HappinessLevel.excited.rawValue, location: loc,  success: {(entry: Entry) in
            self.entryLabel.attributedText = NSAttributedString.init(string: entry.text!)
            
            self.entryPFImageView.file = entry.media
            self.entryPFImageView.loadInBackground()
            self.lastAddedEntry = entry
            
        }, failure: {(error: Error) in
            print(error.localizedDescription)
        })
        
    }
    
    @IBAction func onUpdateEntry(_ sender: Any) {
        
        if lastAddedEntry != nil {
            
            lastAddedEntry!.text = "test entry edited"
            let img = UIImage(named: "heartRed")
            //37.425113, -122.094305
            lastAddedEntry?.location?.name = "Google West Campus 5"
            lastAddedEntry?.location?.latitude = 37.425113
            lastAddedEntry?.location?.longitude = -122.094305
            
            HappinessService.sharedInstance.update(entry: lastAddedEntry!, images: [img!], success: { (entry:Entry) in
                
                self.lastEditedEntryLabel.attributedText = NSAttributedString.init(string: entry.text!)
                self.lastEditedEntryImageView.file = entry.media
                self.lastEditedEntryImageView.loadInBackground()
                
            }, failure: { (error:Error) in
                
            })
        }
        
    }
    
    
    @IBAction func onDeleteEntry(_ sender: Any) {
        
         if lastAddedEntry != nil {
            
            HappinessService.sharedInstance.delete(entry: lastAddedEntry!, success: { 
                print("entry deleted")
            }, failure: { (error:Error) in
                
            })
            
        }
    }
    
    @IBAction func onGetUserEntries(_ sender: Any) {
        
        HappinessService.sharedInstance.getEntries(success: { (entries: [Entry]) in
            
            if(entries.count > 0){
                let entryObj = entries[0]
                self.latestCreatedEntryLabel.attributedText = NSAttributedString(string: entryObj.text!)
                self.latestCreatedEntryImageView.file = entryObj.media
                self.latestCreatedEntryImageView.loadInBackground()
                self.lastAddedEntry = entryObj
            }
            
        }, failure: {(error: Error) in
            print(error.localizedDescription)
        })
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

