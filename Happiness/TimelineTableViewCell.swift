//
//  TimelineTableViewCell.swift
//  Happiness
//
//  Created by Dylan Miller on 11/10/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import AFNetworking
import ParseUI

protocol TimelineTableViewCellDelegate: class {
    
    func timelineCellWasTapped(_ cell: TimelineTableViewCell)
}

class TimelineTableViewCell: UITableViewCell {

    @IBOutlet weak var happinessColorView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var monthNameLabel: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var happinessImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var entryImageView: PFImageView!
    
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
    weak var delegate : TimelineTableViewCellDelegate?
    let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
        textView.textContainer.lineBreakMode = .byTruncatingTail
        locationImageView.image = locationImageView.image?.withRenderingMode(.alwaysTemplate)
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0 // circle
        profileImageView.clipsToBounds = true

        // Add a gesture recogizer programatically, since the following
        // error occurs otherwise: "invalid nib registered for identifier
        // (XXXCell) - nib must contain exactly one top level object which
        // must be a UITableViewCell instance."
        let tapGestureRecognizer =
            UITapGestureRecognizer(target: self, action: #selector(onTextViewTap(_:)))
        tapGestureRecognizer.cancelsTouchesInView = true
        tapGestureRecognizer.numberOfTapsRequired = 1
        textView.addGestureRecognizer(tapGestureRecognizer)
    }

    @IBAction func onTextViewTap(_ sender: UITapGestureRecognizer) {
        
        // We use a tap gesture recognizer for the text view, since
        // otherwise taps on the UITextView will not register as selecting
        // a cell.
        if sender.state == .ended
        {
            if let delegate = delegate
            {
                delegate.timelineCellWasTapped(self)
            }
        }
    }

    // Set the cell contents based on the specified parameters.
    func setData(entry: Entry, delegate: TimelineTableViewCellDelegate) {
        
        self.entry = entry
        self.delegate = delegate
        
        userNameLabel.text = entry.author?.name

        if let happinessLevel = entry.happinessLevel {
        
            happinessColorView.backgroundColor = UIConstants.happinessLevelColor(happinessLevel)
            happinessImageView.image = UIConstants.happinessLevelImage(happinessLevel)
        }
        else {
        
            happinessColorView.backgroundColor = happinessColorView.superview?.backgroundColor
            happinessImageView.image = nil
        }
        
        if let createdDate = entry.createdDate {
            
            let month = Calendar.current.component(.month, from: createdDate)
            monthNameLabel.text = monthNames[month-1]

            let day = Calendar.current.component(.day, from: createdDate)
            dayNumberLabel.text = String(format: "%02d", day)

            let weekday = Calendar.current.component(.weekday, from: createdDate)
            dayNameLabel.text = dayNames[weekday-1]            
        }
        else {
        
            dayNameLabel.text = nil
            dayNumberLabel.text = nil
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

        if let entryImageFile = entry.media {
            
            // Create entryImageView aspect ratio constraint to match
            // image aspect ratio.
            let aspect: CGFloat = 4.0 / 3.0 // Should be image width/height!!!
            entryImageViewAspectConstraint = NSLayoutConstraint(
                item: entryImageView,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: entryImageView,
                attribute: NSLayoutAttribute.height,
                multiplier: aspect,
                constant: 0.0)

            entryImageView.image = nil
            entryImageView.file = entryImageFile
            entryImageView.loadInBackground()
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
            
            entryImageView.file = nil
            entryImageView.image = nil
        }
    }
}
