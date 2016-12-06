//
//  ViewEntryTableViewCell.swift
//  Happiness
//
//  Created by Dylan Miller on 11/10/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import AFNetworking
import ParseUI

class ViewEntryTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var happinessImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var entryImageView: PFImageView!
    
    var happinessImageView2: UIImageView!

    var entryImageViewAspectConstraint : NSLayoutConstraint? {
        
        didSet {
            
            if let oldAspectConstraint = oldValue {
                
                entryImageView.removeConstraint(oldAspectConstraint)
            }
            if let aspectConstraint = entryImageViewAspectConstraint {
                
                aspectConstraint.priority = 999 // avoid LayoutConstraints error
                entryImageView.addConstraint(aspectConstraint)
            }
        }
    }
    
    var entry: Entry?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
        textView.textContainer.lineBreakMode = .byTruncatingTail
        locationImageView.image = locationImageView.image?.withRenderingMode(.alwaysTemplate)
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0 // circle
        profileImageView.clipsToBounds = true
        entryImageView.layer.cornerRadius = 3
        entryImageView.clipsToBounds = true
    }

    // Set the cell contents based on the specified parameters.
    func setData(entry: Entry, isComingFromTimeline: Bool) {
        
        self.entry = entry
        
        if let happinessLevel = entry.happinessLevel {
            
            if isComingFromTimeline {
                
                happinessImageView.image = UIConstants.happinessLevelImage(happinessLevel)
                happinessImageView.transform = CGAffineTransform(
                    scaleX: profileImageView.bounds.width / happinessImageView.bounds.width,
                    y: profileImageView.bounds.height / happinessImageView.bounds.height)
                happinessImageView.center = profileImageView.center
                
                UIView.animate(
                    withDuration: 1.5,
                    animations: {
                    
                        self.happinessImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        let rightBottomPoint = CGPoint(x: self.profileImageView.frame.maxX - 4, y: self.profileImageView.frame.maxY - 4)
                        self.happinessImageView.center = rightBottomPoint
                    },
                    completion: { (finish) in
                    
                        self.happinessImageView.layer.removeAllAnimations()
                    }
                )
            }
        }
        else {
            
            happinessImageView.image = nil
        }
        
        if let createdDate = entry.createdDate {
            
            dateLabel.text = UIConstants.dateString(from: createdDate)
        }
        else {
            
            dateLabel.text = nil
        }

        textView.text = entry.text
        
        if let placemark = entry.placemark {
            
            locationLabel.text = placemark
            locationImageView.isHidden = false
        }
        else {
            
            locationLabel.text = nil
            locationImageView.isHidden = true
        }
        
        if let profileImageFile = entry.author?.profileImage {
            
            profileImageView.image = nil
            profileImageView.file = profileImageFile
            profileImageView.loadInBackground()
        }
        else {
            
            profileImageView.file = nil
            profileImageView.image = nil
        }
        
        if entry.isLocal {
            
            if let localImage = entry.localImage {
                
                setEntryImageViewAspectConstraint(hasImage: true, aspectRatio: entry.aspectRatio)
                entryImageView.file = nil
                entryImageView.image = localImage
            }
            else {
                
                setEntryImageViewAspectConstraint(hasImage: false, aspectRatio: nil)
                entryImageView.file = nil
                entryImageView.image = nil
            }
        }
        else {

            if let entryImageFile = entry.media {
            
                setEntryImageViewAspectConstraint(hasImage: true, aspectRatio: entry.aspectRatio)
                entryImageView.file = entryImageFile
                entryImageView.loadInBackground()
            }
            else {
            
                setEntryImageViewAspectConstraint(hasImage: false, aspectRatio: nil)
                entryImageView.file = nil
                entryImageView.image = nil
            }
        }
    }
    
    // Set the entryImageView aspect ratio constraint based on the image.
    func setEntryImageViewAspectConstraint(hasImage: Bool, aspectRatio: Double?) {
        
        if hasImage {
            
            // Create entryImageView aspect ratio constraint to match
            // image aspect ratio.
            let aspect: CGFloat = CGFloat(aspectRatio ?? (4.0 / 3.0))
            entryImageViewAspectConstraint = NSLayoutConstraint(
                item: entryImageView,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: entryImageView,
                attribute: NSLayoutAttribute.height,
                multiplier: aspect,
                constant: 0.0)
        }
        else {
            
            // No image, create entryImageView height constraint of 0 so
            // that it has no effect on auto layout.
            self.entryImageViewAspectConstraint = NSLayoutConstraint(
                item: entryImageView,
                attribute: NSLayoutAttribute.height,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.notAnAttribute,
                multiplier: 1,
                constant: 0)
        }
    }
}
