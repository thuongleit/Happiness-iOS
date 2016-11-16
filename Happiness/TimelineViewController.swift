//
//  TimelineViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import MBProgressHUD

// Represents a section in a timeline table.
class TimelineSection
{
    let month: Int
    let year: Int
    let title: String
    var entries = [Entry]()
    var rows: Int {
        
        return entries.count
    }
    
    let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    init(month: Int, year: Int) {
        
        self.month = month
        self.year = year
        self.title = monthNames[month-1] + String(format: " %d", year)
    }
    
    // Add the specified entry to the end of the entries array.
    func append(entry: Entry) {
        
        entries.append(entry)
    }
    
    // Add the specified entry to the start of the entries array.
    func prepend(entry: Entry) {
        
        entries.insert(entry, at: 0)
    }
    
    // Return the entry with the specified ID, or nil if no such entry is
    // found.
    func findEntry(_ entryId: String) -> Entry? {
        
        for entry in entries {
            
            if entry.id == entryId
            {
                return entry
            }
        }
        return nil
    }
}

class TimelineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var sections = [TimelineSection]()

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
            navigationItem.title = "Timeline"
            
            // Add the compose button.
            let composeButton = UIBarButtonItem(
                image: UIImage(named: UIConstants.ImageName.composeButton),
                style: .plain,
                target: self,
                action: #selector(onComposeButton))
            navigationItem.rightBarButtonItem  = composeButton
        }
        
        // Set up the tableView.
        tableView.estimatedRowHeight = 125
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(
            UINib(nibName: UIConstants.ClassName.timelineTableViewCellXib, bundle: nil),
            forCellReuseIdentifier: UIConstants.CellReuseIdentifier.timelineCell)
        
        // Create a UIRefreshControl and add it to the tableView.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self, action: #selector(refreshControlAction(_:)),
            for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // When an entry is created, add it to the table.
        NotificationCenter.default.addObserver(
            forName: AppDelegate.GlobalEventEnum.newEntryNotification.notification,
            object: nil,
            queue: OperationQueue.main)
            { (notification: Notification) in
                
                if let entry = notification.object as? Entry {
                    
                    let wasSectionAdded = self.addNewEntry(entry)
                    
                    DispatchQueue.main.async {
                        
                        if wasSectionAdded {
                            
                            // When a section is added, reload the entire table.
                            self.tableView.reloadData()
                        }
                        else {
                            
                            // When the entry was added to the first section,
                            // just reload the first section.
                            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                        }
                    }
                    
                }
            }

        // When an entry is updated, update it in the table.
        NotificationCenter.default.addObserver(
            forName: AppDelegate.GlobalEventEnum.updateEntryNotification.notification,
            object: nil,
            queue: OperationQueue.main)
            { (notification: Notification) in
            
                if let entry = notification.object as? Entry,
                    let updatedSectionIndex = self.updateEntry(entry) {
                    
                    DispatchQueue.main.async {
                        
                        // Reload the updated section.
                        self.tableView.reloadSections(IndexSet(integer: updatedSectionIndex), with: .fade)
                    }
                }
            }
        
        // Get entries when the view controller loads.
        getEntries()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        // Display the tab bar.
        NotificationCenter.default.post(Notification(name: AppDelegate.GlobalEventEnum.unhideBottomTabBars.notification))
    }
 
    // When the compose is pressed, present the EditEntryViewController modally.
    @IBAction func onComposeButton(_ sender: UIBarButtonItem)
    {
        let editEntryViewController = EditEntryViewController(nibName: nil, bundle: nil)
        let navigationController = UINavigationController(rootViewController: editEntryViewController)
        navigationController.navigationBar.isTranslucent = false
        present(navigationController, animated: true, completion: nil)
    }

    // Get a collection of entries for the authenticating user.
    func getEntries(refreshControl: UIRefreshControl? = nil) {
        
        let happinessService = HappinessService.sharedInstance
        
        /* test code!!!
        let entries = getDummyEntries()
        setupSections(entries: entries)
        tableView.reloadData()
        return
        */

        willRequest()
            
        happinessService.getEntries(
            success: { (entries: [Entry]) in

                let shouldReloadData: Bool
                //!!!if self.scrollLoadingData {
                //!!!
                //!!!    // Infinite scroll.
                //!!!    self.scrollLoadingData = false
                //!!!    self.entries.append(contentsOf: entries)
                //!!!    shouldReloadData = entries.count > 0
                //!!!}
                //!!!else {
                    
                    //delete!!!self.entries = entries
                    shouldReloadData = true
                //!!!}
                //!!!self.maxId = nextMaxId
                
                // Set up the tableView sections based on the entries.
                self.addEntries(entries: entries)

                self.requestDidSucceed(true, refreshControl: refreshControl)
                
                if shouldReloadData {
                    
                    DispatchQueue.main.async {
                    
                        self.tableView.reloadData()
                    }
                }
            },
            failure: { (Error) in
                
                self.requestDidSucceed(false, refreshControl: refreshControl)
            }
        )
    }
    
    // Set up the tableView sections based on the entries.
    func addEntries(entries: [Entry]) {
        
        sections.removeAll()
        var section: TimelineSection?
        var sectionMonth = -1
        var sectionYear = -1
        for entry in entries {
            
            let (month, year) = getEntryMonthYear(entry: entry)
            
            if section == nil || month != sectionMonth || year != sectionYear {
                
                sectionMonth = month
                sectionYear = year
                section = TimelineSection(month: month, year: year)
                sections.append(section!)
            }
            
            section!.append(entry: entry)
        }
    }
    
    // Add the specified new entry to the tableView sections. Returns true
    // if a new section was added, false otherwise.
    func addNewEntry(_ entry: Entry) -> Bool {
        
        let (month, year) = getEntryMonthYear(entry: entry)
        
        let section: TimelineSection
        let wasSectionAdded: Bool
        if sections.count > 0 && sections[0].month == month && sections[0].year == year {
            
            section = sections[0]
            wasSectionAdded = false
        }
        else {
            
            section = TimelineSection(month: month, year: year)
            sections.insert(section, at: 0)
            wasSectionAdded = true
        }
        
        section.prepend(entry: entry)
        
        return wasSectionAdded
    }
    
    // Updates the specified entry in the tableView, if found. Returns the
    // section index of the updated entry, or nil if no entry was updated.
    func updateEntry(_ entry: Entry) -> Int? {
        
        if let entryId = entry.id
        {
            var sectionIndex = 0
            for section in sections {
                
                var foundEntry = section.findEntry(entryId)
                if foundEntry != nil
                {
                    
                    // foundEntry and entry may or may not reference the same
                    // Entry object, so we copy entry to foundEntry.
                    foundEntry = entry
                    return sectionIndex
                }
                sectionIndex = sectionIndex + 1
            }
        }
        return nil
    }
    
    // Return the month and year of the specified entry.
    func getEntryMonthYear(entry: Entry) -> (Int, Int) {
        
        let month: Int
        let year: Int
        if let createdDate = entry.createdDate {
            
            month = Calendar.current.component(.month, from: createdDate)
            year = Calendar.current.component(.year, from: createdDate)
        }
        else {
            
            month = 0
            year = 0
        }
        
        return (month, year)
    }
    
    // Get entries when the user pulls to refresh.
    func refreshControlAction(_ refreshControl: UIRefreshControl) {

        getEntries(refreshControl: refreshControl)
    }
    
    // Display progress HUD before the request is made.
    func willRequest() {
        
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    // Show or hide the error banner based on success or failure. Hide the
    // progress HUD. If the optional refreshControl parameter is specified,
    // tell it to stop spinning.
    func requestDidSucceed(_ success: Bool, refreshControl: UIRefreshControl?) {
        
        DispatchQueue.main.async {
            
            if !success {
            
                if let navigationController = self.navigationController {
                    
                    UIConstants.presentError(message: "Network Error", inView: navigationController.view)
                }
            }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let refreshControl = refreshControl {
                
                refreshControl.endRefreshing()
            }
        }
    }
    
    // Push the ViewEntryViewController for the specified entry.
    func pushViewEntryViewController(forEntry entry: Entry) {
        
        let viewEntryViewController = ViewEntryViewController(nibName: nil, bundle: nil)
        viewEntryViewController.entry = entry
        NotificationCenter.default.post(Notification(name: AppDelegate.GlobalEventEnum.hideBottomTabBars.notification))
        navigationController?.pushViewController(viewEntryViewController, animated: true)
    }
}

// UITableView methods
extension TimelineViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
        return 30 // magic number!!!
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        // Only use upper case for the first letter of each word.
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.text = header.textLabel?.text?.capitalized
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UIConstants.CellReuseIdentifier.timelineCell) as! TimelineTableViewCell
        
        // Set the cell contents.
        cell.setData(entry: sections[indexPath.section].entries[indexPath.row], delegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Push the ViewEntryViewController.
        pushViewEntryViewController(
            forEntry: sections[indexPath.section].entries[indexPath.row])
        
        // Do not leave rows selected.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Swipe to delete
        if editingStyle == .delete
        {
            let happinessService = HappinessService.sharedInstance
            
            willRequest()
            
            happinessService.delete(
                entry: sections[indexPath.section].entries[indexPath.row],
                success: { () in
                    
                    // Remove the entry from the section. To simplify the
                    // tableView reloading code, we currently do not remove
                    // a section with zero entries.
                    self.sections[indexPath.section].entries.remove(at: indexPath.row)

                    self.requestDidSucceed(true, refreshControl: nil)
                    
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
                    }
                },
                failure: { (Error) in
                    
                    self.requestDidSucceed(false, refreshControl: nil)
                }
            )

        }
    }
}

// TimelineTableViewCell methods
extension TimelineViewController: TimelineTableViewCellDelegate {
    
    func timelineCellWasTapped(_ cell: TimelineTableViewCell) {
        
        // Push the ViewEntryViewController when a cell was tapped, but
        // a tableView didSelectRowAt call did not occur.
        if let entry = cell.entry {
            
            pushViewEntryViewController(forEntry: entry)
        }
    }
}

extension TimelineViewController {
    
    // test function!!!
    /*func getDummyEntries() -> [Entry]
     {
     var entries = [Entry]()
     let entry0 = Entry()
     entry0.question = nil
     entry0.text = "Feeling grateful as I watch the sun rise over the rim of the Grand Canyon."
     entry0.imageUrls = [URL(string: "https://i.imgur.com/m9KiEJs.jpg")!]
     entry0.location = Location(locationObject: [:] as AnyObject)
     entry0.location?.name = "Grand Canyon National Park, Arizona"
     entry0.createdDate = Date() // today
     entry0.happinessLevel = .happy
     entries.append(entry0)
     
     let entry1 = Entry()
     entry1.question = nil
     entry1.text = "Such a happy day in Paris today. The Eiffel Tower was lit up with the colors of the South African flag in honour of Nelson Mandela."
     entry1.imageUrls = [URL(string: "https://i.imgur.com/e25gpSJ.jpg")!]
     entry1.location = Location(locationObject: [:] as AnyObject)
     entry1.location?.name = "Paris, France"
     var dateComponents = DateComponents()
     dateComponents.day = 6
     dateComponents.month = 12
     dateComponents.year = 2015
     entry1.createdDate = Calendar.current.date(from: dateComponents)
     entry1.happinessLevel = .happy
     entries.append(entry1)
     
     let entry2 = Entry()
     entry2.question = nil
     entry2.text = "Having kind of a down day. Made some cranberry and white chocolate chip cookies to cheer myself up."
     entry2.imageUrls = [URL(string: "https://i.imgur.com/CEKaBVb.jpg")!]
     entry2.location = Location(locationObject: [:] as AnyObject)
     entry2.location?.name = "Menlo Park, CA"
     dateComponents.day = 29
     dateComponents.month = 1
     dateComponents.year = 2015
     entry2.createdDate = Calendar.current.date(from: dateComponents)
     entry2.happinessLevel = .sad
     entries.append(entry2)
     
     let entry3 = Entry()
     entry3.question = nil
     entry3.text = "Just landed in Bali for this year's rafting trip. Last year was a blast! I can't wait to get out there. So grateful to meet up with good friends in such a wonderful country. John is already here, and Lisa is arriving tomorrow."
     entry3.imageUrls = [URL(string: "https://i.imgur.com/MW8zU.jpg")!]
     entry3.location = Location(locationObject: [:] as AnyObject)
     entry3.location?.name = "Badung, Bali, Indonesia"
     dateComponents.day = 5
     dateComponents.month = 1
     dateComponents.year = 2015
     entry3.createdDate = Calendar.current.date(from: dateComponents)
     entry3.happinessLevel = .excited
     entries.append(entry3)
     
     let entry4 = Entry()
     entry4.question = nil
     entry4.text = "San Francisco lit up city hall quite nicely with their green and red color-changing display. It took forever to get zero people in the shot, but it was worth the wait."
     entry4.imageUrls = [URL(string: "https://i.imgur.com/I6nM7wb.jpg")!]
     entry4.location = Location(locationObject: [:] as AnyObject)
     entry4.location?.name = "San Francisco, CA"
     dateComponents.day = 24
     dateComponents.month = 12
     dateComponents.year = 2014
     entry4.createdDate = Calendar.current.date(from: dateComponents)
     entry4.happinessLevel = .happy
     entries.append(entry4)
     
     return entries
     }*/
}
