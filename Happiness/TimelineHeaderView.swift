//
//  TimelineHeaderTableViewCell.swift
//  Happiness
//
//  Created by Carina Boo on 11/20/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

@objc protocol TimelineHeaderViewDelegate {
    
    @objc optional func timelineHeaderView(headerView: TimelineHeaderView, didTapOnProfileImage toNudgeUser: User?, profileImageView: PFImageView)
    
}

class TimelineHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    weak var delegate: TimelineHeaderViewDelegate?
    
    // Array of profile imageViews. Initialized when nestUsers is set.
    var profileImagesByUserId = [String: PFImageView]()

    var entryCountByUser: [String: Int]?
    
    var completedUserCount: Int?
    
    var shouldDisplayCompletionEffect: Bool?
    
    var section: TimelineSection? {
        didSet {
            self.entryCountByUser = section?.getEntryCountByUser()
            self.completedUserCount = section?.getCountOfUsersWithEntries()
            self.shouldDisplayCompletionEffect = section?.currentUserMadeFirstEntry
        }
    }
    
    var bouncingImageView: PFImageView?
    
    var nestUsers: [User]? {
        didSet {
            // Remove old profile image views
            for (userId, imageView) in profileImagesByUserId {
                imageView.removeFromSuperview()
            }
            
            profileImagesByUserId = [String: PFImageView]()
            
            // Set profiles and message label
            for (index, user) in nestUsers!.enumerated() {
                let imageView = PFImageView(frame: CGRect(x: 12 + index*8 + index*60, y: 34, width: 60, height:60))
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                
                // Set image
                if let profileImageFile = user.profileImage {
                    imageView.file = profileImageFile
                    imageView.load(inBackground: { (image: UIImage?, error: Error?) in
                        
                        if (self.section!.currentUserMadeFirstEntry) {

                            if (user.id == User.currentUser?.id) {
                                
                                self.bouncingImageView = imageView
                            
                                imageView.layer.borderColor = UIConstants.whiteColor.cgColor
                                
                                imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                                
                                DispatchQueue.main.async {
                                    UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 12.0, options: .curveEaseInOut, animations: {
                                    
                                        self.bouncingImageView?.transform = .identity
                                        
                                    }, completion: { (finished) in
                                        
                                    })
                                }
                                
                                self.section?.currentUserMadeFirstEntry = false
                            }
                            
                        } else {
                            if let image = image {
                                // Blue border if completed entry
                                if let entryCount = self.entryCountByUser?[user.id!] {
                                    if entryCount > 0 {
                                        imageView.layer.borderColor = UIConstants.whiteColor.cgColor
                                    } else {
                                        imageView.image = UIConstants.convertToGrayScale(image: image)
                                        imageView.layer.borderColor = UIConstants.darkGrayColor.cgColor
                                    }
                                } else {
                                    // Pink border and grayed-out image if not completed entry
                                    imageView.image = UIConstants.convertToGrayScale(image: image)
                                    imageView.layer.borderColor = UIConstants.darkGrayColor.cgColor
                                }
                            }
                        }
                        
                    })
                    
                    
                    
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.cornerRadius = imageView.bounds.width / 2.0 // circle
                    imageView.clipsToBounds = true
                    
                    // Border
                    imageView.layer.borderWidth = 2
                    imageView.layer.masksToBounds = true
                    
                } else {
                    imageView.image = nil
                }
                
                profileImagesByUserId[user.id!] = imageView
                contentView.addSubview(imageView)
                
                let tap = UITapGestureRecognizer()
                tap.numberOfTapsRequired = 1
                imageView.tag = index
                tap.addTarget(self, action: #selector(profileImageTap))
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(tap)
            }
            
            // Message text
            let userCount: Int! = nestUsers?.count
            let completedUserCount = self.completedUserCount ?? 0
            if completedUserCount == nestUsers?.count {
                // Everyone completed
                messageLabel.text = "Woohoo! Everyone completed! ^_^"
                // Set text and background colors
                messageLabel.textColor = UIConstants.whiteColor
                contentView.backgroundColor = UIConstants.headerEveryoneCompleteColor
            }
            else if completedUserCount < (nestUsers?.count)! {
                if let currentUserEntryCount = entryCountByUser?[(User.currentUser?.id)!] {
                    if currentUserEntryCount > 0 {
                        // Your pals have not completed
                        messageLabel.text = "\(userCount - completedUserCount) pal" + (userCount - completedUserCount > 1 ? "s " : " ") + "didn't write!"
                        // Set text and background colors
                        messageLabel.textColor = UIConstants.whiteColor
                        contentView.backgroundColor = UIConstants.headerSomeoneIncompleteColor
                    } else {
                        messageLabel.text = "You didn't write! :("
                        // Set text and background colors
                        messageLabel.textColor = UIConstants.secondaryThemeColor
                        contentView.backgroundColor = UIConstants.headerYouIncompleteColor
                    }
                } else {
                    // You have not completed
                    messageLabel.text = "You didn't write! :("
                    // Set text and background colors
                    messageLabel.textColor = UIConstants.secondaryThemeColor
                    contentView.backgroundColor = UIConstants.headerYouIncompleteColor
                }
            }
        }
    }
    
    func profileImageTap(sender: UITapGestureRecognizer) {
        let user = nestUsers?[(sender.view?.tag)!]
        delegate?.timelineHeaderView?(headerView: self, didTapOnProfileImage: user, profileImageView: sender.view as! PFImageView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
