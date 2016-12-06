//
//  TimelineViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import ParseUI

class TimelineViewController: ViewControllerBase, TimelineHeaderViewDelegate, JBKenBurnsViewDelegate, CompilationAlertViewDelegate, NudgeAlertViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var confettiView: ConfettiView?
    
    var sections = [TimelineSection]()
    var nestUsers = [User]()
    var progressHud: ProgressHUD?
    var scrollLoadingData = false
    var lastEntryCreatedDate: Date?
    
    var nudgeView: UIView!
    var nudgeAlertVC: NudgeAlertViewController!
    
    var centerX: CGFloat = UIScreen.main.bounds.width / 2
    var centerY: CGFloat = UIScreen.main.bounds.height / 2

    lazy var compilationView: CompilationOverlayView = {
        let compilationView = CompilationOverlayView()
        return compilationView
    }()
    var compilationImages = [UIImage]()
    var noOfEntriesInCurrentWeek = 0
    
    lazy var compilationAlertView: CompilationAlertView = {
        let compilationAlertView = CompilationAlertView()
        return compilationAlertView
    }()
    
    var newEntryObserver: NSObjectProtocol?
    var replaceEntryObserver: NSObjectProtocol?
    var deleteEntryObserver: NSObjectProtocol?

    deinit {

        // Remove all of this object's observers. For block-based observers,
        // we need a separate removeObserver(observer:) call for each observer.
        if let newEntryObserver = newEntryObserver {

            NotificationCenter.default.removeObserver(newEntryObserver)
        }
        if let replaceEntryObserver = replaceEntryObserver {

            NotificationCenter.default.removeObserver(replaceEntryObserver)
        }
        if let deleteEntryObserver = deleteEntryObserver {
            
            NotificationCenter.default.removeObserver(deleteEntryObserver)
        }
    }
    
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
        tableView.estimatedSectionHeaderHeight = 130
        // Changed sectionHeaderHeight from UITableViewAutomaticDimension to 130
        // to prevent exception: "'NSInternalInconsistencyException', reason:
        // 'Missing cell for newly visible row X'"
        tableView.sectionHeaderHeight = 130 //UITableViewAutomaticDimension
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
        newEntryObserver = NotificationCenter.default.addObserver(
            forName: AppDelegate.GlobalEventEnum.newEntryNotification.notification,
            object: nil,
            queue: OperationQueue.main)
        { [weak self] (notification: Notification) in
            
            if let _self = self,
                let entry = notification.object as? Entry {
                
                let sectionWasAdded = _self.addNewEntry(entry)
                
                DispatchQueue.main.async {
                    
                    if sectionWasAdded {
                        
                        // When a section is added, reload the entire table.
                        _self.tableView.reloadData()
                    }
                    else {
                        
                        // When the entry was added to the first section,
                        // just reload the first section.
                        _self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                    }
                    
                    // Scroll to top when an entry is created.
                    _self.tableView.setContentOffset(CGPoint(x: 0, y: 0 - _self.tableView.contentInset.top), animated: true)
                    
                    // Congratulate user when appropriate.
                    _self.congratulateIfComplete()
                }
            }
        }
        
        // When an entry is replaced, update it in the table.
        replaceEntryObserver = NotificationCenter.default.addObserver(
            forName: AppDelegate.GlobalEventEnum.replaceEntryNotification.notification,
            object: nil,
            queue: OperationQueue.main)
        { [weak self] (notification: Notification) in
            
            if let _self = self,
                let replaceEntryObject = notification.object as? ReplaceEntryNotificationObject,
                let entryReplacedInSectionIndex = _self.replaceEntry(withId: replaceEntryObject.entryId, replacementEntry: replaceEntryObject.replacementEntry) {
                
                DispatchQueue.main.async {
                    
                    // Reload the section containing the replaced entry.
                    // Save/restore the contentOffset, since when this is not
                    // done the table sometimes scrolls away from an updated
                    // entry. Saving/restoring does not completely fix this,
                    // but it helps.
                    let contentOffset = _self.tableView.contentOffset
                    if replaceEntryObject.useFadeAnimation {
                        
                        _self.tableView.reloadSections(IndexSet(integer: entryReplacedInSectionIndex), with: .fade)
                    }
                    else {
                        
                        // Reload the updated section without animating, since a
                        // replacement when the timeline is visible will often be
                        // of an updated entry replacing a local entry, so they will
                        // be identical.
                        UIView.performWithoutAnimation({
                            _self.tableView.reloadSections(IndexSet(integer: entryReplacedInSectionIndex), with: .none)
                        })
                    }
                    _self.tableView.contentOffset = contentOffset
                }
            }
        }
        
        // When an entry is deleted, remove it from the table.
        deleteEntryObserver = NotificationCenter.default.addObserver(
            forName: AppDelegate.GlobalEventEnum.deleteEntryNotification.notification,
            object: nil,
            queue: OperationQueue.main)
        { [weak self] (notification: Notification) in
            
            if let _self = self,
                let entry = notification.object as? Entry,
                let entryDeletedInSectionIndex = _self.deleteEntry(entry) {
                
                DispatchQueue.main.async {
                    
                    // Reload the section the entry was deleted from.
                    _self.tableView.reloadSections(IndexSet(integer: entryDeletedInSectionIndex), with: .fade)
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
    
    //for ken burns compilation on entry images
    func loadImagesForCompilation() {
        
        self.compilationImages = [UIImage]()
        if let firstSection = sections.first {
            let streakEntries = firstSection.entries
            noOfEntriesInCurrentWeek = streakEntries.count
            
            for entry in streakEntries {
                if(entry.media != nil){
                    
                    //asynchronous
                    entry.media?.getDataInBackground(block: { (data: Data?, error: Error?) in
                        if(error == nil){
                            
                            let image = UIImage(data: data!)
                            if(image != nil){
                                self.compilationImages.append(image!)
                                //after loading all images asynchronously check if you got all entries for the week and present compilation
                                if(self.noOfEntriesInCurrentWeek == self.compilationImages.count){
                                    self.presentUserCompilationViewPrompt()
                                }
                            }
                        }
                    })
                    
                } else if(entry.localImage != nil) {
                    self.compilationImages.append(entry.localImage!)
                    //after loading all images asynchronously check if you got all entries for the week and present compilation
                    if(self.noOfEntriesInCurrentWeek == self.compilationImages.count){
                        self.presentUserCompilationViewPrompt()
                    }
                }
            }
        }
    }
    
    //custom view to show the prompt
    func presentUserCompilationViewPrompt(){
        compilationAlertView.compileAlertDelegate = self
        compilationAlertView.displayView(onView: view)
    }
    
    func compilationActionTakenByUser(isShow: Bool) {
        if(isShow){
            startCompilation()
        }
        self.compilationAlertView.hideView()
    }
    
    func startCompilation() {
        self.compilationView.kenBurnsView.kenBurnsDelegate = self
        self.compilationView.alpha = 0.0
        let parentFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.compilationView.frame = parentFrame
        self.compilationView.kenBurnsView.frame = parentFrame
        self.view.addSubview(self.compilationView)
        
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.compilationView.alpha = 1.0
        }, completion: nil)
        
        self.compilationView.kenBurnsView.animateWithImages(compilationImages, imageAnimationDuration: 5, initialDelay: 0.6, shouldLoop: false)
        
        //        var imagesArray = [UIImage]()
        //        imagesArray.append(UIImage(named: "1")!)
        //        imagesArray.append(UIImage(named: "2")!)
        //        imagesArray.append(UIImage(named: "3")!)
        //        imagesArray.append(UIImage(named: "4")!)
        //        self.compilationView.kenBurnsView.animateWithImages(imagesArray, imageAnimationDuration: 5, initialDelay: 0, shouldLoop: false)
    }
    
    func finishedShowingLastImage() {
        self.compilationView.removeFromSuperview()
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
        let sectionWasAdded: Bool
        if sections.count > 0 && sections[0].week == week && sections[0].year == year {
            
            section = sections[0]
            sectionWasAdded = false
        }
        else {
            
            section = TimelineSection(week: week, year: year)
            sections.insert(section, at: 0)
            sectionWasAdded = true
        }
        
        section.prepend(entry: entry)
        
        return sectionWasAdded
    }
    
    // Replaces the specified entry in the tableView, if found. Returns the
    // section index of the replaced entry, or nil if no entry was replaced.
    func replaceEntry(withId entryId: String, replacementEntry: Entry) -> Int? {
        
        for (sectionIndex, section) in sections.enumerated() {
            
            let entryWasReplaced = section.replace(entryWithId: entryId, replacementEntry: replacementEntry)
            if entryWasReplaced {
                
                return sectionIndex
            }
        }
        return nil
    }
    
    // Deletes the specified entry from the tableView, if found. Returns the
    // section index of the deleted entry, or nil if no entry was deleted.
    func deleteEntry(_ entry: Entry) -> Int? {
        
        for (sectionIndex, section) in sections.enumerated() {
            
            // To simplify the tableView reloading code, we currently do not
            // remove a section with zero entries.
            let entryWasDeleted = section.remove(entry: entry)
            if entryWasDeleted {
                
                return sectionIndex
            }
        }
        return nil
    }
    
    // Get nest users and entries when the user pulls to refresh.
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // Disable pull to refresh when there are temporary "local" entries.
        var hasLocalEntries = false
        for section in sections {
            
            if section.localEntriesCount > 0 {
                
                hasLocalEntries = true
                break
            }
        }
        if hasLocalEntries {
            
            refreshControl.endRefreshing()
            return
        }
        
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
        viewEntryViewController.comingfromTimeline = true
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
                self.loadImagesForCompilation() //load all images to show the ken burns effect.
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
        
        APNUtil.sendConratulations(toNestUsers: nestUsers, completionBlock: {(isSuccess) -> () in
            
        })
        
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let entry = sections[indexPath.section].get(entryAtRow: indexPath.row)
        if entry.isLocal && entry.isLocalMarkedForDelete {
            
            // Hide cells of entries marked for deletion.
            return 0
        }
        else {
            
            return tableView.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Push the ViewEntryViewController.
        pushViewEntryViewController(
            forEntry: sections[indexPath.section].get(entryAtRow: indexPath.row))
        
        // Do not leave rows selected.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Only allow swipe to delete for current user's entries which are
        // not temporary "local" entries.
        let entry = sections[indexPath.section].get(entryAtRow: indexPath.row)
        if let entryUserId = entry.author?.id,
            let currentUserId = User.currentUser?.id,
            entryUserId == currentUserId,
            !entry.isLocal {
            
            return true
        }
        else {
            
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Swipe to delete
        if editingStyle == .delete {
            
            EntryBroker.shared.deleteEntry(entry: sections[indexPath.section].get(entryAtRow: indexPath.row))
        }
    }
    
    func timelineHeaderView(headerView: TimelineHeaderView, didTapOnProfileImage toNudgeUser: User?, profileImageView: PFImageView) {
        
        self.view.layer.removeAllAnimations()
        
        nudgeView = UIView()
        self.view.addSubview(nudgeView)
        
        nudgeView.layer.cornerRadius = 3
        nudgeView.clipsToBounds = true
        
        nudgeAlertVC = NudgeAlertViewController(nibName: "NudgeAlertViewController", bundle: nil)
        nudgeAlertVC.delegate = self
        nudgeAlertVC.user = toNudgeUser
        
        self.addChildViewController(nudgeAlertVC)
        nudgeAlertVC.view.frame = nudgeView.bounds
        nudgeAlertVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        nudgeView.addSubview(nudgeAlertVC.view)
        nudgeAlertVC.didMove(toParentViewController: self)
        
        
        let actualFrame = profileImageView.convert(profileImageView.bounds, to: self.view)
        let centerPoint = CGPoint(x: actualFrame.minX + profileImageView.bounds.width / 2, y: actualFrame.minY + profileImageView.bounds.height / 2)
        nudgeView.frame = CGRect(x: centerPoint.x, y: centerPoint.y, width: 0, height: 0)
        
        UIView.animate(withDuration: 0.7, animations: {

            let width = UIScreen.main.bounds.width - 50
            let height = 260
        
            self.nudgeView.frame = CGRect(x: 0, y: 0, width: Int(width), height: height)
            
            if self.view.frame.minY != 0 {
                self.centerY = self.centerY - self.view.frame.minY
            }
            
            self.nudgeView.center = CGPoint(x: self.centerX, y: self.centerY)
            
        }, completion: { (finish) in
           
        })
        
    }
    
    func nudgeAlertViewController(nudgeAlertViewController: NudgeAlertViewController, didRespond toNudge: Bool, toNudgeUser: User) {
        
        if (toNudge) {
            let nudgeMessage = "\(User.currentUser!.name!) is reminding you to finish this week's challenge!"
            APNUtil.sendNudging(targetEmail: toNudgeUser.email!, withMessage: nudgeMessage, completionBlock: { (result) in
                if result == true {
                    UIConstants.presentError(message: "\(toNudgeUser.name!) is being reminded to finish the challenge!", inView: (self.navigationController?.view)!)
                } else {
                    UIConstants.presentError(message: "Hmm something went wrong.", inView: (self.navigationController?.view)!)
                }
            })

        }
        
        UIView.animate(withDuration: 0.1, animations: {
            
            self.nudgeView.center = CGPoint(x: self.nudgeView.center.x, y: self.nudgeView.center.y - 50)
            
        }, completion: { (finished) in
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.nudgeView.center = CGPoint(x: self.centerX, y: self.centerY + 500)
                
            }, completion: { (finished) in
                
                self.centerY = UIScreen.main.bounds.height / 2
                self.nudgeAlertVC.willMove(toParentViewController: nil)
                self.nudgeAlertVC.view.removeFromSuperview()
                self.nudgeAlertVC.removeFromParentViewController()
                self.nudgeAlertVC.didMove(toParentViewController: nil)
                self.nudgeAlertVC = nil
                self.nudgeView = nil
            
            })
        })
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

