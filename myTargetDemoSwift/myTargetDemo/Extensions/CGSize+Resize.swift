//
//  CGSize+Resize.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 05.10.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

extension CGSize {

	func resize(targetSize: CGSize) -> CGSize {
		guard
			width != 0, height != 0,
			targetSize.width != 0, targetSize.height != 0
		else {
			return .zero
		}

		let widthRatio  = targetSize.width / width
		let heightRatio = targetSize.height / height

		if widthRatio > heightRatio {
			return CGSize(width: width * heightRatio, height: height * heightRatio)
		} else {
			return CGSize(width: width * widthRatio, height: height * widthRatio)
		}
	}

}
