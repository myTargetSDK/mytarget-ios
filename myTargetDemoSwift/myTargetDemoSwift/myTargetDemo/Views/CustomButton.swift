//
//  CustomButton.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 23/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

class CustomButton: UIButton
{
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		configure()
	}

	required init?(coder: NSCoder)
	{
		super.init(coder: coder)
		configure()
	}

	override func tintColorDidChange()
	{
		super.tintColorDidChange()
		applyDarkMode()
	}

	private func configure()
	{
		layer.borderWidth = 0.3
		layer.cornerRadius = 4.0
		applyDarkMode()
	}

	func applyDarkMode()
	{
		let foregroundColor = UIColor.foregroundColor()
		backgroundColor = UIColor.backgroundColor()
		setTitleColor(UIColor.disabledColor(), for: .disabled)
		setTitleColor(foregroundColor, for: .normal)
		layer.borderColor = foregroundColor.cgColor
	}
}
