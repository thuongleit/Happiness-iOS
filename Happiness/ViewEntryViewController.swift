//
//  ViewEntryViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

class ViewEntryViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!

    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var feelingImageView: UIImageView!

    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var photoImageView: PFImageView!


    var entry: Entry!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Naviation bar
        navigationController?.navigationBar.isTranslucent = false
        
        // Navigation bar edit entry
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(ViewEntryViewController.editEntry))
        navigationItem.rightBarButtonItem = editButton
        
        // Location Icon
        locationIconImageView.image = locationIconImageView.image?.withRenderingMode(.alwaysTemplate)
        
        // Set entry data
        if let entry = entry {
            if let profileImageFile = entry.author?.profileImage {
                profileImageView.file = profileImageFile
                profileImageView.loadInBackground()
                profileImageView.clipsToBounds = true
            } else {
                profileImageView.image = nil
            }
            if let date = entry.createdDate {
                dateLabel.text = UIConstants.dateString(from: date)
            }
            if let question = entry.question {
                questionLabel.text = question.text
            }
            if let text = entry.text {
                textLabel.text = text
            }
            if let placemark = entry.placemark {
                locationLabel.text = placemark
            }
            if let happinessLevel = entry.happinessLevel {
                feelingImageView.image = UIConstants.happinessLevelImage(happinessLevel)
            }
            if let photoFile = entry.media {
                photoImageView.file = photoFile
                photoImageView.loadInBackground()
                photoImageView.clipsToBounds = true
            } else {
                photoImageView.image = nil
            }
        }
        
        // Reload view if entry was updated
         NotificationCenter.default.addObserver(self, selector: #selector(ViewEntryViewController.reloadView), name: AppDelegate.GlobalEventEnum.updateEntryNotification.notification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Edit current entry
    func editEntry() {
        // Show the EditEntryViewController modally.
        let editEntryViewController = EditEntryViewController(nibName: nil, bundle: nil)
        editEntryViewController.entry = entry
        let navigationController = UINavigationController(rootViewController: editEntryViewController)
        navigationController.navigationBar.isTranslucent = false
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Notification
    func reloadView(notification: NSNotification) {
        if let entry = notification.object as? Entry {
            self.entry = entry
            viewDidLoad()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
