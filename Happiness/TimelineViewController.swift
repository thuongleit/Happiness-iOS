//
//  TimelineViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import MBProgressHUD

class TimelineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    class Section
    {
        let title: String
        var entries = [Entry]()
        var rows: Int {
            
            return entries.count
        }
        
        init(title: String) {

            self.title = title
        }
        
        func add(entry: Entry) {

            entries.append(entry)
        }
    }
    var sections = [Section]()

    let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Set the navigationBar color.
        if let navigationController = navigationController {

            navigationController.navigationBar.barTintColor = UIColor(red: 0xFB/255.0, green: 0xF8/255.0, blue: 0xF4/255.0, alpha: 1.0) // magic numbers!!!
        }
        
        // Render the bar button images using the correct color.
        navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem?.image = navigationItem.rightBarButtonItem?.image?.withRenderingMode(.alwaysOriginal)
        
        // Hide the error banner.
        //!!!errorBannerView.isHidden = true
        
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
        
        // Get entries when the view controller loads.
        getEntries()
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
                self.setupSections(entries: entries)

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
    func setupSections(entries: [Entry]) {
        
        sections.removeAll()
        var section: Section?
        var sectionMonth = -1
        var sectionYear = -1
        for entry in entries {
            
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
            
            if section == nil || month != sectionMonth || year != sectionYear {
                
                sectionMonth = month
                sectionYear = year
                let title = monthNames[month-1] + String(format: " %d", year)
                section = Section(title: title)
                sections.append(section!)
            }
            
            section!.add(entry: entry)
        }
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
            
            //!!!self.errorBannerView.isHidden = success
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let refreshControl = refreshControl {
                
                refreshControl.endRefreshing()
            }
        }
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
      
        return 30 //!!!
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
        cell.setData(entry: sections[indexPath.section].entries[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Perform a segue to the ViewEntryViewController.
        /*
        let viewEntryViewController = ViewEntryViewController(nibName: nil, bundle: nil)
        let navigationController = UINavigationController(rootViewController: viewEntryViewController)
        self.present(navigationController, animated: true, completion: nil)*/
        
        // Do not leave rows selected.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // test function!!!
    func getDummyEntries() -> [Entry]
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
    }
}

/*!!!
 Test app delegate code:
 
 let timelineViewController = TimelineViewController(nibName: nil, bundle: nil)
 timelineViewController.title = "Journal"//!!!
 let navigationController = UINavigationController(rootViewController: timelineViewController)
 self.window = UIWindow(frame: UIScreen.main.bounds)
 self.window?.rootViewController = navigationController
 self.window?.makeKeyAndVisible()
*/
