//
//  TimelineTableViewCell.swift
//  Happiness
//
//  Created by Dylan Miller on 11/10/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import AFNetworking

class TimelineTableViewCell: UITableViewCell {

    @IBOutlet weak var happinessColorView: UIView!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var happinessImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var questionLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabelTrailingConstraint: NSLayoutConstraint!
    
    let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
        textView.textContainer.lineBreakMode = .byTruncatingTail
        locationImageView.image = locationImageView.image?.withRenderingMode(.alwaysTemplate)
        entryImageView.layer.cornerRadius = 3
        entryImageView.clipsToBounds = true
    }

    // Set the cell contents based on the specified parameters.
    func setData(entry: Entry) {
        
        // Use real colors!!!
        // magic strings!!!
        if let happinessLevel = entry.happinessLevel {
        
            switch happinessLevel {
                
            case .sad:
                happinessColorView.backgroundColor = UIColor.blue
                happinessImageView.image = UIImage(named: "sad-240")?.withRenderingMode(.alwaysTemplate)
            case .happy:
                happinessColorView.backgroundColor = UIColor.green
                happinessImageView.image = UIImage(named: "happy-240")?.withRenderingMode(.alwaysTemplate)
            case .excited:
                happinessColorView.backgroundColor = UIColor.orange
                happinessImageView.image = UIImage(named: "excited-240")?.withRenderingMode(.alwaysTemplate)
            }
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
        
        textView.text = entry.text?.string // attributed?!!!
        
        locationLabel.text = entry.location?.name
        
        let hasImage: Bool
        if let imageUrls = entry.imageUrls,
            imageUrls.count > 0 {
            
            setImage(imageView: entryImageView, imageUrl: imageUrls[0])
            hasImage = true
        }
        else {
            
            entryImageView.image = nil
            hasImage = false
        }

        // Adjust constraints.
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
    
    // Fade in the specified image if it is not cached, or simply update
    // the image if it was cached.
    func setImage(imageView: UIImageView, imageUrl: URL) {
        
        imageView.image = nil
        let imageRequest = URLRequest(url: imageUrl)
        imageView.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (request: URLRequest, response: HTTPURLResponse?, image: UIImage) in
                
                DispatchQueue.main.async {
                    
                    let imageIsCached = response == nil
                    if !imageIsCached {
                        
                        imageView.alpha = 0.0
                        imageView.image = image
                        UIView.animate(
                            withDuration: 0.3,
                            animations: { () -> Void in
                                
                                imageView.alpha = 1.0
                            }
                        )
                    }
                    else {
                        
                        imageView.image = image
                    }
                }
            },
            failure: { (request: URLRequest, response: HTTPURLResponse?, error: Error) in
                
                DispatchQueue.main.async {
                    
                    imageView.image = nil
                }
            }
        )
    }
}
