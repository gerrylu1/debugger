//
//  AppDelegate.swift
//  Debugger
//
//  Created by Gerry Low on 2020-06-23.
//  Copyright © 2020 Gerry Low. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    static let keyForHasLaunchedBefore = "hasLaunchedBefore"
    static let keyForHasInitDefaultLevels = "hasInitDefaultLevels"
    static let keyForHasDisplayedTipForPlayer = "hasDisplayedTipForPlayer"
    static let keyForHasDisplayedTipForLevelMaker = "hasDisplayedTipForLevelMaker"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkIfFirstLaunch()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - App Initializer
    
    func checkIfFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: AppDelegate.keyForHasLaunchedBefore) {
            UserDefaults.standard.set(true, forKey: AppDelegate.keyForHasLaunchedBefore)
            UserDefaults.standard.set(false, forKey: AppDelegate.keyForHasInitDefaultLevels)
            UserDefaults.standard.set(false, forKey: AppDelegate.keyForHasDisplayedTipForPlayer)
            UserDefaults.standard.set(false, forKey: AppDelegate.keyForHasDisplayedTipForLevelMaker)
        }
    }
    
}

