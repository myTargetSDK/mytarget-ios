//
//  AppDelegate.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19/06/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import AppTrackingTransparency
import MyTargetSDK

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        MTRGManager.setDebugMode(true)
        
        if #available(iOS 13.0, *) {
            // scene
        } else {
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

    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    print("Tracking Authorization Status: Not determined")
                case .restricted:
                    print("Tracking Authorization Status: Restricted")
                case .denied:
                    print("Tracking Authorization Status: Denied")
                case .authorized:
                    print("Tracking Authorization Status: Authorized")
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }

}
