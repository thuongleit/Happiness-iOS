//
//  TimelineViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

// Represents a section in a timeline table.
class TimelineSection
{
    let week: Int
    let year: Int
    let title: String
    private var entries = [Entry]()
    private var userEntryCount = [String: Int]() // maps user IDs to entry counts
    
    var rows: Int {
        
        var currentUserEntryCount = 0
        if let currentUserId = User.currentUser?.id,
            let _currentUserEntryCount = userEntryCount[currentUserId] {
                
            currentUserEntryCount = _currentUserEntryCount
        }
        
        // Only display entries for milestone if current user created an
        // entry for that milestone.
        return currentUserEntryCount > 0 ? entries.count : 0
    }
    
    init(week: Int, year: Int) {
        
        self.week = week
        self.year = year
        self.title = String(format: "Week %d, %d", week, year)
    }
    
    // Add the specified entry to the end of the entries array.
    func append(entry: Entry) {
        
        if let userId = entry.author?.id {
            
            userEntryCount[userId] = (userEntryCount[userId] ?? 0) + 1
        }

        entries.append(entry)
    }
    
    // Add the specified entry to the start of the entries array.
    func prepend(entry: Entry) {
        
        if let userId = entry.author?.id {
            
            userEntryCount[userId] = (userEntryCount[userId] ?? 0) + 1
        }
        
        entries.insert(entry, at: 0)
    }
    
    // Remove the specified entry from the entries array.
    func remove(entryAtRow atRow: Int) {

        let entry = entries[atRow]
        if let userId = entry.author?.id {
            
            userEntryCount[userId] = (userEntryCount[userId] ?? 0) - 1
        }
        
        entries.remove(at: atRow)
    }
    
    // Return the specified entry from the entries array.
    func get(entryAtRow atRow: Int) -> Entry {
        
        return entries[atRow]
    }
    
    // Return the entry with the specified ID, or nil if no such entry is
    // found.
    func get(entryWithId entryId: String) -> Entry? {
        
        for entry in entries {
            
            if entry.id == entryId {
                
                return entry
            }
        }
        return nil
    }
    
    // Return the count of entries for the specified user, or nil if no
    // such user has entries.
    func getEntryCount(userWithId userId: String) -> Int? {
        
        return userEntryCount[userId]
    }
    
    // Return the count of users who have at least one entry.
    func getCountOfUsersWithEntries() -> Int {
        
        var countOfUsersWithEntries = 0
        for (_, entryCount) in userEntryCount {
            
            if entryCount > 0 {
                
                countOfUsersWithEntries = countOfUsersWithEntries + 1
            }
        }
        return countOfUsersWithEntries
    }
    
    // Returns a dictionary of user id to count of entries written for each user
    // in the current user's nest.
    func getEntryCountByUser() -> [String: Int]? {
        
        return userEntryCount
    }
}

class TimelineViewController: UIViewController, TimelineHeaderViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var confettiView: ConfettiView?
    
    var sections = [TimelineSection]()
    var nestUsers = [User]()
    var progressHud: ProgressHUD?
    var scrollLoadingData = false
    var lastEntryCreatedDate: Date?

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
            
            // Add the settings button.
            let settingsButton = UIBarButtonItem(
                image: UIImage(named: UIConstants.ImageName.settingsButton),
                style: .plain,
                target: self,
                action: #selector(onSettingsButton))
            navigationItem.leftBarButtonItem  = settingsButton

            // Add the compose button.
            let composeButton = UIBarButtonItem(
                image: UIImage(named: UIConstants.ImageName.composeButton),
                style: .plain,
                target: self,
                action: #selector(onComposeButton))
            navigationItem.rightBarButtonItem  = composeButton
        }
        
        // Set up the tableView.
        tableView.estimatedSectionHeaderHeight = 80
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 438
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(
            UINib(nibName: UIConstants.ClassName.timelineTableHeaderViewCellXib, bundle: nil),
            forHeaderFooterViewReuseIdentifier: UIConstants.CellReuseIdentifier.timelineHeaderCell)
        tableView.register(
            UINib(nibName: UIConstants.ClassName.timelineTableViewCellXib, bundle: nil),
            forCellReuseIdentifier: UIConstants.CellReuseIdentifier.timelineCell)
        
        // Create a UIRefreshControl and add it to the tableView.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self, action: #selector(refreshControlAction(_:)),
            for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Set up the ProgressHUD.
        progressHud = ProgressHUD(view: view)
        if let progressHud = progressHud {
            
            view.addSubview(progressHud)
        }
        
        // Set up confetti view.
        confettiView = ConfettiView(frame: view.bounds)
        if let confettiView = confettiView {
            
            view.addSubview(confettiView)
        }
        
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
                        
                        // Congratulate user when appropriate.
                        self.congratulateIfComplete()
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
        
        // Get nest users and entries when the view controller loads.
        getNestUsers(thenGetEntries: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Display the tab bar.
        //NotificationCenter.default.post(Notification(name: AppDelegate.GlobalEventEnum.unhideBottomTabBars.notification))
    }
 
    // When the settings is pressed, log out.
    @IBAction func onSettingsButton(_ sender: UIBarButtonItem)
    {
        NotificationCenter.default.post(name: AppDelegate.GlobalEventEnum.didLogout.notification, object: nil)
    }

    // When the compose is pressed, present the EditEntryViewController modally.
    @IBAction func onComposeButton(_ sender: UIBarButtonItem)
    {
        // Enforce a limit of maxEntriesPerWeek.
        if let firstSection = sections.first {
            
            if firstSection.rows + 1 > HappinessService.maxEntriesPerWeek {
                
                if let navigationController = self.navigationController {
                    
                    UIConstants.presentError(
                        message: "Max entries per week reached.",
                        inView: navigationController.view)
                }
                return
            }
        }

        let editEntryViewController = EditEntryViewController(nibName: nil, bundle: nil)
        let navigationController = UINavigationController(rootViewController: editEntryViewController)
        navigationController.navigationBar.isTranslucent = false
        present(navigationController, animated: true, completion: nil)
    }
    
    // Set nestUsers[] array to the list of users in the authenticating user's
    // nest. If shouldGetEntries parameter is true, call getEntries() after this
    // function has succeeded.
    func getNestUsers(
        thenGetEntries shouldGetEntries: Bool, refreshControl: UIRefreshControl? = nil) {
        
        let happinessService = HappinessService.sharedInstance
        
        willRequest()
        
        happinessService.getNestUsersForCurrentUser(
            success: { (users: [User]) in
            
                self.nestUsers = users

                // When calling getEntries(), do not hide progressHud or end
                // refreshing on refreshControl at this time.
                if !shouldGetEntries {
                    
                    self.requestDidSucceed(
                        true, refreshControl: shouldGetEntries ? nil : refreshControl)
                }
                
                DispatchQueue.main.async {
                    
                    if shouldGetEntries {
                        
                        self.getEntries(willRequestCalled: true, refreshControl: refreshControl)
                    }
                    else {
                        
                        self.tableView.reloadData()
                    }
                }
            },
            failure: { (error: Error) in
            
                self.requestDidSucceed(false, refreshControl: refreshControl)
            }
        )
    }

    // Get a collection of entries for the authenticating user.
    func getEntries(willRequestCalled: Bool = false, refreshControl: UIRefreshControl? = nil) {
        
        let happinessService = HappinessService.sharedInstance
        
        if !willRequestCalled {
            
            willRequest()
        }
        
        happinessService.getEntries(
            beforeCreatedDate: scrollLoadingData ? lastEntryCreatedDate : nil,
            success: { (entries: [Entry]) in

                let entriesAdded: Int
                let shouldReloadData: Bool
                if self.scrollLoadingData {
                
                    // Infinite scroll. Append entries to tableView.
                    self.scrollLoadingData = false
                    entriesAdded = self.appendEntries(entries: entries)
                    shouldReloadData = entries.count > 0
                }
                else {
                    
                    // Set up the tableView based on entries.
                    entriesAdded = self.addEntries(entries: entries)
                    shouldReloadData = true
                }
                if entriesAdded > 0 {
                    
                    self.lastEntryCreatedDate = entries[entriesAdded - 1].createdDate
                }
                
                self.requestDidSucceed(true, refreshControl: refreshControl)
                
                if shouldReloadData {
                    
                    DispatchQueue.main.async {
                    
                        self.tableView.reloadData()
                        
                        // Congratulate user when appropriate.
                        self.congratulateIfComplete()
                    }
                }
            },
            failure: { (Error) in
                
                self.requestDidSucceed(false, refreshControl: refreshControl)
            }
        )
    }
    
    // Replace the contents of the tableView with the specified entries.
    // Returns the number of entries added.
    func addEntries(entries: [Entry]) -> Int {
        
        sections.removeAll()
        let entriesAdded = appendEntries(entries: entries)
        
        // Add section for the current week even if it has no entries.
        let (thisWeek, thisYear) = UIConstants.getWeekYear(date: Date())
        if !(sections.count > 0 && sections[0].week == thisWeek && sections[0].year == thisYear) {
            
            let section = TimelineSection(week: thisWeek, year: thisYear)
            sections.insert(section, at: 0)
        }
        
        return entriesAdded
    }
    
    // Append the specified entries to the tableView. Returns the number of
    // entries added.
    func appendEntries(entries: [Entry]) -> Int {
        
        var section = sections.last
        var sectionsAdded = 0
        for entry in entries {
            
            let (week, year) = UIConstants.getWeekYear(date: entry.createdDate)
            
            if section == nil || week != section!.week || year != section!.year {
                
                section = TimelineSection(week: week, year: year)
                sections.append(section!)
                sectionsAdded = sectionsAdded + 1
            }
            
            section!.append(entry: entry)
        }

        // If these entries are not the final entries in the database, discard
        // the final section, since it may not be complete. This code makes the
        // assumption that there is always less than getEntriesQueryLimit entries
        // in a section. This is enforced elsewhere using maxEntriesPerWeek.
        var entriesAdded = entries.count
        let endOfDatabase = entriesAdded < HappinessService.sharedInstance.getEntriesQueryLimit
        if sectionsAdded > 0 && !endOfDatabase {
            
            if let lastSection = sections.last {
                
                entriesAdded -= lastSection.rows
                sections.removeLast()
            }
        }
        
        return entriesAdded
    }
    
    // Add the specified new entry to the tableView sections. Returns true
    // if a new section was added, false otherwise.
    func addNewEntry(_ entry: Entry) -> Bool {
        
        let (week, year) = UIConstants.getWeekYear(date: entry.createdDate)
        
        let section: TimelineSection
        let wasSectionAdded: Bool
        if sections.count > 0 && sections[0].week == week && sections[0].year == year {
            
            section = sections[0]
            wasSectionAdded = false
        }
        else {
            
            section = TimelineSection(week: week, year: year)
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
                
                var foundEntry = section.get(entryWithId: entryId)
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
        
    // Get nest users and entries when the user pulls to refresh.
    func refreshControlAction(_ refreshControl: UIRefreshControl) {

        getNestUsers(thenGetEntries: true, refreshControl: refreshControl)
    }
    
    // Display progress HUD before the request is made.
    func willRequest() {
        
        if let progressHud = progressHud {
        
            progressHud.show(animated: true)
        }
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
            
            if let progressHud = self.progressHud {
                
                progressHud.hide(animated: true)
            }
            
            if let refreshControl = refreshControl {
                
                refreshControl.endRefreshing()
            }
        }
    }
    
    // Push the ViewEntryViewController for the specified entry.
    func pushViewEntryViewController(forEntry entry: Entry) {
        
        let viewEntryViewController = ViewEntryViewController(nibName: nil, bundle: nil)
        viewEntryViewController.entry = entry
        //NotificationCenter.default.post(Notification(name: AppDelegate.GlobalEventEnum.hideBottomTabBars.notification))
        navigationController?.pushViewController(viewEntryViewController, animated: true)
    }
    
    // Congratulate user if all nest users have completed the challenge and the
    // user has not been congratulated yet for this week. Should be called after
    // entries are added.
    func congratulateIfComplete() {
        
        if sections.count > 0,
            sections[0].getCountOfUsersWithEntries() == nestUsers.count {
            
            if Congrats.shared.congratulateShouldDisplayCongrats() {
                
                displayCongrats()
            }
        }
    }
    
    // Display a congratulations banner and confetti.
    func displayCongrats()
    {
        if let navigationController = self.navigationController {
            
            UIConstants.presentError(
                message: "Everyone completed the challenge!!!",
                inView: navigationController.view)
        }
        if let confettiView = confettiView {
            
            // Make it rain.
            confettiView.drop(seconds: 1.8)
        }
    }
}

// UITableView methods
extension TimelineViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: UIConstants.CellReuseIdentifier.timelineHeaderCell) as! TimelineHeaderView
        headerView.delegate = self
        headerView.entryCountByUser = self.sections[section].getEntryCountByUser()
        headerView.completedUserCount = self.sections[section].getCountOfUsersWithEntries()
        headerView.nestUsers = self.nestUsers
        headerView.titleLabel.text = sections[section].title
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
        return 130 // TODO(cboo): Fix auto height. Not working even though I have it in self.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UIConstants.CellReuseIdentifier.timelineCell) as! TimelineTableViewCell
        
        // Set the cell contents.
        cell.setData(entry: sections[indexPath.section].get(entryAtRow: indexPath.row), delegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Push the ViewEntryViewController.
        pushViewEntryViewController(
            forEntry: sections[indexPath.section].get(entryAtRow: indexPath.row))
        
        // Do not leave rows selected.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Only allow swipe to delete for current user's entries.
        let entry = sections[indexPath.section].get(entryAtRow: indexPath.row)
        if let entryUserId = entry.author?.id,
            let currentUserId = User.currentUser?.id,
            entryUserId == currentUserId {
            
            return true
         
        }
        else {
            
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Swipe to delete
        if editingStyle == .delete
        {
            let happinessService = HappinessService.sharedInstance
            
            willRequest()
            
            happinessService.delete(
                entry: sections[indexPath.section].get(entryAtRow: indexPath.row),
                success: { () in
                    
                    // Remove the entry from the section. To simplify the
                    // tableView reloading code, we currently do not remove
                    // a section with zero entries.
                    self.sections[indexPath.section].remove(entryAtRow: indexPath.row)

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
    
    func timelineHeaderView(headerView: TimelineHeaderView, didTapOnProfileImage toNudgeUser: User?) {
        let name = toNudgeUser!.name!
        let email = toNudgeUser!.email!
        let nudgeMessage = "\(User.currentUser!.name!) is reminding you to finish this week's challenge!"
        let nudgingAlert = UIAlertController(title: "\(name) hasn't completed this week's challenge yet!", message: "Do you want to give \(name) a nudge?", preferredStyle: .alert)
        nudgingAlert.addAction(UIAlertAction(title: "Sure!", style: .default, handler: { (alert) in
            
            APNUtil.sendNudging(targetEmail: email, withMessage: nudgeMessage, completionBlock: { (result) in
                if result == true {
                    UIConstants.presentError(message: "\(name) is being reminded to finish the challenge!", inView: (self.navigationController?.view)!)
                } else {
                    UIConstants.presentError(message: "Hmm something went wrong.", inView: (self.navigationController?.view)!)
                }
            })
            
        }))
        nudgingAlert.addAction(UIAlertAction(title: "Hmm no", style: .cancel, handler: { (alert) in
            
        }))
        present(nudgingAlert, animated: true, completion: nil)
    }
}

// UIScrollView methods
extension TimelineViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == tableView && !scrollLoadingData)
        {
            // Calculate the position of one screen length before the bottom
            // of the results.
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging)
            {
                scrollLoadingData = true
                
                // Get more entries.
                getEntries()
            }
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
