//
//  UIViewController+SafeArea.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 24.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var supportSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .init(top: topLayoutGuide.length,
                         left: 0,
                         bottom: bottomLayoutGuide.length,
                         right: 0)
        }
    }
    
}
