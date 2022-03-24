//
//  AppDelegate.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19/06/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?

	func applicationDidBecomeActive(_ application: UIApplication)
	{
		if #available(iOS 14.5, *)
		{
			ATTrackingManager.requestTrackingAuthorization
							 { status in
								 switch status
								 {
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
