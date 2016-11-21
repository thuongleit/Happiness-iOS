//
//  TimelineHeaderTableViewCell.swift
//  Happiness
//
//  Created by Carina Boo on 11/20/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

class TimelineHeaderTableViewCell: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    // Array of profile imageViews. Initialized when nestUsers is set.
    var profileImagesByUserId = [String: PFImageView]()

    var entryCountByUser: [String: Int]?
    var nestUsers: [User]? {
        didSet {
            // Remove old profile image views
            for (userId, imageView) in profileImagesByUserId {
                imageView.removeFromSuperview()
            }
            profileImagesByUserId = [String: PFImageView]()
            
            // Set profiles and message label
            for (index, user) in nestUsers!.enumerated() {
                let imageView = PFImageView(frame: CGRect(x: 10 + index*6 + index*60, y: 34, width: 60, height:60))
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                
                // Set image
                if let profileImageFile = user.profileImage {
                    imageView.file = profileImageFile
                    imageView.load(inBackground: { (image: UIImage?, error: Error?) in
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
                    })
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
            }
            
            // Message text
            let userCount: Int! = nestUsers?.count
            let completedUserCount: Int! = entryCountByUser?.count
            if completedUserCount == nestUsers?.count {
                // Everyone completed
                messageLabel.text = "Woohoo! Everyone completed! ^_^"
                // Set text and background colors
                messageLabel.textColor = UIConstants.whiteColor
                contentView.backgroundColor = UIConstants.primarySelectedThemeColor
            }
            if (entryCountByUser?.count)! < (nestUsers?.count)! {
                if let currentUserEntryCount = entryCountByUser?[(User.currentUser?.id)!] {
                    if currentUserEntryCount > 0 {
                        // Your pals have not completed
                        messageLabel.text = "\(userCount - completedUserCount) pal" + (userCount - completedUserCount > 1 ? "s " : " ") + "didn't write!"
                        // Set text and background colors
                        messageLabel.textColor = UIConstants.whiteColor
                        contentView.backgroundColor = UIConstants.secondaryThemeColor
                    } else {
                        messageLabel.text = "You didn't write! :("
                        // Set text and background colors
                        messageLabel.textColor = UIConstants.secondaryThemeColor
                        contentView.backgroundColor = UIConstants.secondarySelectedThemeColor
                    }
                } else {
                    // You have not completed
                    messageLabel.text = "You didn't write! :("
                    // Set text and background colors
                    messageLabel.textColor = UIConstants.secondaryThemeColor
                    contentView.backgroundColor = UIConstants.secondarySelectedThemeColor
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
