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

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var feelingImageView: UIImageView!

    @IBOutlet weak var photoImageView: PFImageView!


    var entry: Entry!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let entry = entry {
            if let date = entry.createdDate {
                dateLabel.text = UIConstants.dateString(from: date)
            }
            if let question = entry.question {
                questionLabel.text = question.text
            }
            if let text = entry.text {
                textLabel.text = text
            }
            if let location = entry.location {
                locationLabel.text = UIConstants.locationString(from: location)
            }
            if let happinessLevel = entry.happinessLevel {
                feelingImageView.image = UIConstants.happinessLevelImage(happinessLevel)
            }
            if let photoFile = entry.media {
                photoImageView.file = photoFile
                photoImageView.loadInBackground()
            } else {
                photoImageView.image = nil
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
