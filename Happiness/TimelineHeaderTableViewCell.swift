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

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!

    var nestUsers: [User]? {
        didSet {
            if let profileImageFile = nestUsers?[0].profileImage {
                profileImageView.file = profileImageFile
                profileImageView.loadInBackground()
                profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0 // circle
                profileImageView.clipsToBounds = true
            } else {
                profileImageView.image = nil
            }
        }
    }
    var entryCountByUser: [String: Int]? {
        didSet {
            print(entryCountByUser ?? "nothing")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
