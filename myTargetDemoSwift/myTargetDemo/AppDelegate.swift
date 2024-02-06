//
//  AppDelegate.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19/06/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        MTRGManager.setDebugMode(true)

        if #unavailable(iOS 13.0) {
            let viewController = MainViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.navigationBar.tintColor = .foregroundColor()

            window = UIWindow()
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }

        return true
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}
