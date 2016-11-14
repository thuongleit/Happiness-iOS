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
    }

    // Set the cell contents based on the specified parameters.
    func setData(entry: Entry) {
        
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
        
        locationLabel.text = entry.location?.name
        
        let hasImage: Bool
        if let entryImageFile = entry.media {
            
            hasImage = true
            entryImageView.file = entryImageFile
            entryImageView.loadInBackground()
        }
        else {
            
            hasImage = false
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
