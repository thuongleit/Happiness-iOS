//
//  ViewEntryScrollingViewController.swift
//  Happiness
//
//  Created by Dylan Miller on 12/5/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class ViewEntryScrollingViewController: ViewControllerBase {

    @IBOutlet weak var tableView: UITableView!
    
    var isComingFromTimeline = false

    var entry: Entry!

    deinit {
        
        // Remove all of this object's observer entries.
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Navigation bar
        navigationController?.navigationBar.isTranslucent = false
                
        // Set the navigation bar back button.
        let backButton = UIBarButtonItem(
            image: UIImage(named: UIConstants.ImageName.backButton), style: .plain, target: self, action: #selector(ViewEntryScrollingViewController.onBackButton))
        navigationItem.leftBarButtonItem = backButton

        // Set the navigation bar edit button.
        if User.currentUser?.id == entry.author?.id {
            
            let editButton = UIBarButtonItem(
                image: UIImage(named: UIConstants.ImageName.composeButton), style: .plain, target: self, action: #selector(ViewEntryScrollingViewController.onEditButton))
            navigationItem.rightBarButtonItem = editButton
            navigationItem.rightBarButtonItem?.isEnabled = !entry.isLocal
        }
        
        // Set up the tableView.
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(
            UINib(nibName: UIConstants.ClassName.viewEntryTableViewCellXib, bundle: nil),
            forCellReuseIdentifier: UIConstants.CellReuseIdentifier.timelineCell)
        
        // Reload tableView if entry was edited.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewEntryScrollingViewController.replaceEntry), name: AppDelegate.GlobalEventEnum.replaceEntryNotification.notification, object: nil)
    }
    
    // MARK: - Back button
    func onBackButton() {
        
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Edit button
    func onEditButton() {
        
        // Show the EditEntryViewController modally.
        let editEntryViewController = EditEntryViewController(nibName: nil, bundle: nil)
        editEntryViewController.entry = entry
        let navigationController = UINavigationController(rootViewController: editEntryViewController)
        navigationController.navigationBar.isTranslucent = false
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Notification
    func replaceEntry(notification: NSNotification) {
        
        if let replaceEntryObject = notification.object as? ReplaceEntryNotificationObject {
            
            entry = replaceEntryObject.replacementEntry
            navigationItem.rightBarButtonItem?.isEnabled = !entry.isLocal
            tableView.reloadData()
        }
    }
}

// UITableView methods
extension ViewEntryScrollingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UIConstants.CellReuseIdentifier.timelineCell) as! ViewEntryTableViewCell
        
        // Set the cell contents.
        cell.setData(entry: entry, isComingFromTimeline: isComingFromTimeline)
        
        // Only display emoji animation once.
        isComingFromTimeline = false

        return cell
    }
}
