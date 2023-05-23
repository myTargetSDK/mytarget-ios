//
//  UIView+SafeArea.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 24.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

extension UIView {

    var supportSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return safeAreaInsets
        } else {
            return parentViewController?.supportSafeAreaInsets ?? .zero
        }
    }

}

private extension UIResponder {

    var parentViewController: UIViewController? {
        next as? UIViewController ?? next?.parentViewController
    }

}
