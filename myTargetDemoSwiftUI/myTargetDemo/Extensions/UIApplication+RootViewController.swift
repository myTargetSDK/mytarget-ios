//
//  UIApplication+RootViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 02.02.2023.
//  Copyright © 2023 VK. All rights reserved.
//

import UIKit

extension UIApplication {

    static func rootViewController() -> UIViewController? {
	    let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
	    return scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }

}
