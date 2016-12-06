//
//  ViewControllerBase.swift
//  Happiness
//
//  Created by Dylan Miller on 12/1/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class ViewControllerBase: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        
        // EntryBroker keeps a reference to the current view controller.
        EntryBroker.shared.currentViewController = self
    }

    override func viewWillDisappear(_ animated: Bool) {

        // Remove EntryBroker reference to the current view controller.
        if EntryBroker.shared.currentViewController == self {

            EntryBroker.shared.currentViewController = nil
        }
    }
}
