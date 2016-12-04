//
//  ViewEntryViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

class ViewEntryViewController: ViewControllerBase {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!

    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var feelingImageView: UIImageView!

    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var photoImageView: PFImageView!


    var entry: Entry!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Naviation bar
        navigationController?.navigationBar.isTranslucent = false
        
        // Navigation bar edit entry
        if (User.currentUser?.id == entry.author?.id) {
            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(ViewEntryViewController.editEntry))
            navigationItem.rightBarButtonItem = editButton
        }
        
        // Location Icon
        locationIconImageView.image = locationIconImageView.image?.withRenderingMode(.alwaysTemplate)
        
        // Set static entry data
        if let entry = entry {
            if let profileImageFile = entry.author?.profileImage {
                profileImageView.file = profileImageFile
                profileImageView.loadInBackground()
                profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0 // circle
                profileImageView.clipsToBounds = true
            } else {
                profileImageView.image = nil
            }
        }
        
        // Set variable entry data
        setVariableEntryData()
        
        // Reload view if entry was updated
        NotificationCenter.default.addObserver(self, selector: #selector(ViewEntryViewController.reloadView), name: AppDelegate.GlobalEventEnum.replaceEntryNotification.notification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setVariableEntryData() {
        
        if let entry = entry {
            navigationItem.rightBarButtonItem?.isEnabled = !entry.isLocal
            if let date = entry.createdDate {
                dateLabel.text = UIConstants.dateString(from: date)
            }
            if let text = entry.text {
                textLabel.text = text
            }
            if let placemark = entry.placemark {
                locationLabel.text = placemark
            }
            if let happinessLevel = entry.happinessLevel {
                feelingImageView = UIImageView(frame: self.profileImageView.frame)
                self.view.addSubview(self.feelingImageView)
                feelingImageView.image = UIConstants.happinessLevelImage(happinessLevel)
                
                UIView.animate(withDuration: 2, animations: { 
                    self.feelingImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    
                    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
                    rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                    rotateAnimation.fromValue = 0.0
                    rotateAnimation.toValue = CGFloat(M_PI * 8.0)
                    rotateAnimation.duration = 2.0
                    rotateAnimation.repeatCount = 1
                    self.feelingImageView.layer.add(rotateAnimation, forKey: nil)
                    
                    let rightBottomPoint = CGPoint(x: self.profileImageView.frame.maxX - 10, y: self.profileImageView.frame.maxY - 10)
                    self.feelingImageView.center = rightBottomPoint
                }, completion: { (finish) in
                    self.feelingImageView.layer.removeAllAnimations()
                })
                
            }
            if entry.isLocal {
                if let localImage = entry.localImage {
                    photoImageView.file = nil
                    photoImageView.image = localImage
                }
                else {
                    photoImageView.file = nil
                    photoImageView.image = nil
                }
            }
            else {
                if let photoFile = entry.media {
                    photoImageView.file = photoFile
                    photoImageView.loadInBackground()
                    photoImageView.clipsToBounds = true
                }
                else {
                    photoImageView.file = nil
                    photoImageView.image = nil
                }
            }
        }
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
        if let replaceEntryObject = notification.object as? ReplaceEntryNotificationObject {
            self.entry = replaceEntryObject.replacementEntry
            setVariableEntryData()
        }
    }
}
