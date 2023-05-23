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

    static func secondaryBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondarySystemBackground
        } else {
            return UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
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

    static func activeColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBlue
        } else {
            return UIColor.blue
        }
    }

    static func lightGrayColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray5
        } else {
            return UIColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1)
        }
    }
}
