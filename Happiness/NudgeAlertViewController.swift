//
//  NudgeAlertViewController.swift
//  Happiness
//
//  Created by James Zhou on 12/4/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

@objc protocol NudgeAlertViewControllerDelegate {
    
    @objc optional func nudgeAlertViewController(nudgeAlertViewController: NudgeAlertViewController, didRespond toNudge: Bool, toNudgeUser: User)
    
}

class NudgeAlertViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: PFImageView!
    
    var user: User!
    
    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet weak var promptLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    
    weak var delegate: NudgeAlertViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.backgroundColor = UIConstants.primarySelectedThemeColor

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.file = user.profileImage
        profileImageView.loadInBackground()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        
        promptLabel.text = "\(user.name!) hasn't completed this week's challenge yet! Want to send a nudge?"
        promptLabel.textColor = UIColor.white
        promptLabel.textAlignment = .center
        promptLabel.font = UIFont(name: UIConstants.textFontName, size: 18)
        
        noButton.setTitle("Hmm, no.", for: .normal)
        noButton.layer.cornerRadius = 5
        noButton.clipsToBounds = true
        noButton.backgroundColor = UIConstants.happinessLevelColor(HappinessLevel.bothered)
        noButton.setTitleColor(UIConstants.whiteColor, for: .normal)
        noButton.addTarget(self, action: #selector(noPressed), for: .touchUpInside)
        
        yesButton.setTitle("Yes, sure!", for: .normal)
        yesButton.layer.cornerRadius = 5
        yesButton.clipsToBounds = true
        yesButton.backgroundColor = UIConstants.happinessLevelColor(HappinessLevel.superExcited)
        yesButton.setTitleColor(UIConstants.whiteColor, for: .normal)
        yesButton.addTarget(self, action: #selector(yesPressed), for: .touchUpInside)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func noPressed() {
        self.delegate?.nudgeAlertViewController?(nudgeAlertViewController: self, didRespond: false, toNudgeUser: user)
    }
    
    func yesPressed() {
        self.delegate?.nudgeAlertViewController?(nudgeAlertViewController: self, didRespond: true, toNudgeUser: user)
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
