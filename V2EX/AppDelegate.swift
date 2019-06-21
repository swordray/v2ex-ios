//
//  AppDelegate.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/7/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Firebase
import Regex
import SnapKit
import SwiftDate
import UIButtonSetBackgroundColorForState

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        SwiftDate.defaultRegion = Region(calendar: Calendars.gregorian, zone: Zones.asiaShanghai, locale: Locales.chinese)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            (TopicsController(), UITabBarItem(tabBarSystemItem: .featured, tag: 0)),
            (NodesController(), UITabBarItem(tabBarSystemItem: .mostViewed, tag: 1)),
            (MoreController(), UITabBarItem(tabBarSystemItem: .more, tag: 2)),
        ].map { viewController, tabBarItem in
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.tabBarItem = tabBarItem
            return navigationController
        }
        tabBarController.viewControllers?[1].tabBarItem.setValue("节点", forKey: "internalTitle")

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        return true
    }
}
