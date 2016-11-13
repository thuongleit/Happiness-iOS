//
//  BaseViewController.swift
//  Happiness
//
//  Created by James Zhou on 11/9/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, TabBarViewDelegate {
    
    enum TabSelection: Int {
        case timeline = 0, calendar
    }
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var timelineTabContainerView: UIView!
    
    @IBOutlet weak var calendarTabContainerView: UIView!
    
    var timelineViewController: TimelineViewController!
    
    var calendarViewController: CalendarViewController!
    
    var selectedViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineViewController = TimelineViewController(nibName: "TimelineViewController", bundle: nil)
        calendarViewController = CalendarViewController(nibName: "CalendarViewController", bundle: nil)
        
        if let timelineTab = Bundle.main.loadNibNamed("TabBarView", owner: self, options: nil)?.first as? TabBarView {
            timelineTab.frame = self.timelineTabContainerView.bounds
            timelineTab.delegate = self
            timelineTab.tag = TabSelection.timeline.rawValue
            timelineTab.setTabName(name: "Timeline")
            timelineTab.markSelected()
            self.timelineTabContainerView.addSubview(timelineTab)
        }
        
        if let calendarTab = Bundle.main.loadNibNamed("TabBarView", owner: self, options: nil)?.first as? TabBarView {
            calendarTab.frame = self.calendarTabContainerView.bounds
            calendarTab.delegate = self
            calendarTab.tag = TabSelection.calendar.rawValue
            calendarTab.setTabName(name: "Calendar")
            calendarTab.markUnselected()
            self.calendarTabContainerView.addSubview(calendarTab)
        }
        
    }
    
    func tabBarView(didTapButton tabBarView: TabBarView) {
        switch tabBarView.tag {
        case TabSelection.timeline.rawValue:
            self.switchToViewController(viewController: timelineViewController)
            break
        case TabSelection.calendar.rawValue:
            self.switchToViewController(viewController: calendarViewController)
            break
        default:
            break
        }
    }
    
    func switchToViewController(viewController: UIViewController) {
        
        if let oldViewController = selectedViewController {
            oldViewController.willMove(toParentViewController: nil)
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
        }

        self.addChildViewController(viewController)
        viewController.view.frame = self.contentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        selectedViewController = viewController
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
