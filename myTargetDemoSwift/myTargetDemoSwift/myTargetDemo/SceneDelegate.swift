//
//  SceneDelegate.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 17.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import AppTrackingTransparency

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }

        let viewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.tintColor = .foregroundColor()

        window = UIWindow(windowScene: scene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

	@available(iOS 13.0, *)
	func sceneDidBecomeActive(_ scene: UIScene) {
		if #available(iOS 14.0, *) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
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
			})
		}
	}
}
