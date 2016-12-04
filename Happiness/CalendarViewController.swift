//
//  CalendarViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class CalendarViewController: ViewControllerBase {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the navigation bar.
        if let navigationController = navigationController {
            
            // Set the navigation bar background color.
            navigationController.navigationBar.barTintColor = UIConstants.primaryThemeColor
            
            // Set the navigation bar text and icon color.
            navigationController.navigationBar.tintColor = UIConstants.textLightColor
            navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIConstants.textLightColor]
            
            // Set the navigation bar title.
            navigationItem.title = "Calendar"
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
