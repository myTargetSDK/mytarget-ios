//
//  UIColor+DarkMode.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 23/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

extension UIColor {
    
	static func foregroundColor() -> UIColor {
		if #available(iOS 13.0, *) {
			return UIColor.label
		} else {
			return UIColor.black
		}
	}

	static func backgroundColor() -> UIColor {
		if #available(iOS 13.0, *) {
			return UIColor.systemBackground
		} else {
			return UIColor.white
		}
	}

	static func disabledColor() -> UIColor {
		if #available(iOS 13.0, *) {
			return UIColor.secondaryLabel
		} else {
			return UIColor.lightGray
		}
	}

	static func separatorColor() -> UIColor {
		if #available(iOS 13.0, *) {
			return UIColor.separator
		} else {
			return UIColor.lightGray
		}
	}
}
