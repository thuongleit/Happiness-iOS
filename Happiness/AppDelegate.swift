//
//  AppDelegate.swift
//  Happiness
//
//  Created by James Zhou on 11/1/16.
//  Copyright © 2016 Team Happiness. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    enum GlobalEventEnum: String {
        case didLogin = "userDidLoginNotification"
        case didLogout = "userDidLogoutNotification"
        case newEntryNotification = "newEntryCreated"
        case updateEntryNotification = "entryUpdated"
        
        var notification : Notification.Name {
            return Notification.Name(rawValue: self.rawValue)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogOut), name: GlobalEventEnum.didLogout.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogIn), name: GlobalEventEnum.didLogin.notification, object: nil)
        
        let serviceInstance = HappinessService.sharedInstance
        Parse.setApplicationId(serviceInstance.parseApplicationID, clientKey: serviceInstance.parseClientKey)
        
        if (PFUser.current() != nil) {
            presentLoggedInScreens()
        } else {
            presentLoginSignupScreens()
        }

        return true
    }
    
    func presentLoginSignupScreens() {
        let initialViewController = InitialViewController(nibName: "InitialViewController", bundle: nil)
        let initialNavigationController = UINavigationController(rootViewController: initialViewController)
        initialNavigationController.isNavigationBarHidden = true
        self.window?.rootViewController = initialNavigationController
    }
    
    func presentLoggedInScreens() {
        let baseViewController = BaseViewController(nibName: "BaseViewController", bundle: nil)
        window?.rootViewController = baseViewController
    }
    
    func userDidLogOut() {
        PFUser.logOut()
        presentLoginSignupScreens()
    }
    
    func userDidLogIn() {
        presentLoggedInScreens()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

