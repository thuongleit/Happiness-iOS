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

protocol TimelineTableViewCellDelegate: class
{
    func timelineCellWasTapped(_ cell: TimelineTableViewCell)
}

class TimelineTableViewCell: UITableViewCell {

    @IBOutlet weak var happinessColorView: UIView!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var happinessImageView: UIImageView!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var entryImageView: PFImageView!
    @IBOutlet weak var questionLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabelTrailingConstraint: NSLayoutConstraint!
    
    var entry: Entry?
    weak var delegate : TimelineTableViewCellDelegate?
    let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
        questionImageView.image = questionImageView.image?.withRenderingMode(.alwaysTemplate)
        answerImageView.image = answerImageView.image?.withRenderingMode(.alwaysTemplate)
        textView.textContainer.lineBreakMode = .byTruncatingTail
        locationImageView.image = locationImageView.image?.withRenderingMode(.alwaysTemplate)
        entryImageView.layer.cornerRadius = 3
        entryImageView.clipsToBounds = true

        
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

        if let happinessLevel = entry.happinessLevel {
        
            happinessColorView.backgroundColor = UIConstants.happinessLevelColor(happinessLevel)
            happinessImageView.image = UIConstants.happinessLevelImage(happinessLevel)
        }
        else {
        
            happinessColorView.backgroundColor = happinessColorView.superview?.backgroundColor
            happinessImageView.image = nil
        }
        
        if let createdDate = entry.createdDate {
            
            let weekday = Calendar.current.component(.weekday, from: createdDate)
            dayNameLabel.text = dayNames[weekday-1]
            
            let day = Calendar.current.component(.day, from: createdDate)
            dayNumberLabel.text = String(format: "%02d", day)
        }
        else {
        
            dayNameLabel.text = nil
            dayNumberLabel.text = nil
        }
        
        questionLabel.text = entry.question?.text
        
        textView.text = entry.text
        
        if let location = entry.location {
            
            locationLabel.text = UIConstants.locationString(from: location)
            locationImageView.isHidden = false;
        }
        else {
            
            locationLabel.text = nil
            locationImageView.isHidden = true;
        }
        
        let hasImage: Bool
        if let entryImageFile = entry.media {
            
            hasImage = true
            entryImageView.file = entryImageFile
            entryImageView.loadInBackground()
        }
        else {
            
            hasImage = false
            entryImageView.file = nil
            entryImageView.image = nil
        }
        
        // Adjust constraints.
        let defaultQuestionLabelLeadingConstraint: CGFloat = 66
        let defaultTextViewLeadingConstraint: CGFloat = 61
        let noQAImagesLeadingAdjustment: CGFloat = -12
        if questionLabel.text != nil {
            
            questionImageView.isHidden = false
            answerImageView.isHidden = false
            questionLabelLeadingConstraint.constant = defaultQuestionLabelLeadingConstraint
            textViewLeadingConstraint.constant = defaultTextViewLeadingConstraint
        }
        else {
            
            questionImageView.isHidden = true
            answerImageView.isHidden = true
            questionLabelLeadingConstraint.constant =
                defaultQuestionLabelLeadingConstraint + noQAImagesLeadingAdjustment
            textViewLeadingConstraint.constant =
                defaultTextViewLeadingConstraint + noQAImagesLeadingAdjustment
        }
        
        let defaultMiddleTrailingConstraint: CGFloat = -8
        if hasImage {
            
            questionLabelTrailingConstraint.constant = defaultMiddleTrailingConstraint
            textViewTrailingConstraint.constant = defaultMiddleTrailingConstraint
            locationLabelTrailingConstraint.constant = defaultMiddleTrailingConstraint
        }
        else {

            questionLabelTrailingConstraint.constant = defaultMiddleTrailingConstraint + entryImageView.bounds.width
            textViewTrailingConstraint.constant = defaultMiddleTrailingConstraint + entryImageView.bounds.width
            locationLabelTrailingConstraint.constant = defaultMiddleTrailingConstraint + entryImageView.bounds.width
        }
    }
}
