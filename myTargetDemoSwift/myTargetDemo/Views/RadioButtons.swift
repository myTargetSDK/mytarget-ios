//
//  RadioButtons.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 15/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

class RadioButtonsGroup
{
	@IBOutlet var radioButtons: [RadioButton] = []
	@IBOutlet var selectedButton: RadioButton?

	func addButton(_ button: RadioButton)
	{
		guard !radioButtons.contains(button) else { return }
		button.group = self
		button.index = radioButtons.count
		radioButtons.append(button)
		if button.isSelected
		{
			selectedButton = button
		}
	}

	func addButtons(_ buttons: [RadioButton])
	{
		buttons.forEach { addButton($0) }
	}

	fileprivate func setSelected(button: RadioButton)
	{
		radioButtons.forEach { $0.isSelected = ($0 == button) }
		selectedButton = button
	}
}

@IBDesignable class RadioButton: UIButton
{
	weak fileprivate var group: RadioButtonsGroup?
	fileprivate var index: Int = 0

	var slot = Slot(rawValue: 0)
	var adType = AdvertismentType.standard
	var adDescription = ""

	@IBInspectable var iconWidth: CGFloat = 16.0
	@IBInspectable var iconColor: UIColor?
	@IBInspectable var indicatorColor: UIColor?

	private var activeImage: UIImage?
	private var inactiveImage: UIImage?

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

	init(title: String, frame: CGRect = .zero)
	{
		super.init(frame: frame)
		setTitle(title, for: .normal)
		configure()
	}

	override func tintColorDidChange()
	{
		super.tintColorDidChange()
		activeImage = nil
		inactiveImage = nil
		configure()
	}

	private func configure()
	{
		super.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)

		backgroundColor = UIColor.backgroundColor()
		setTitleColor(UIColor.foregroundColor(), for: .normal)
		setTitleColor(UIColor.disabledColor(), for: .disabled)

		setImage(inactiveIcon(), for: .normal)
		setImage(activeIcon(), for: .selected)
		setImage(activeIcon(), for: [.selected, .highlighted])
	}

	override var isSelected: Bool
	{
		willSet(newValue)
		{
			if isSelected != newValue
			{
				let activeImage = activeIcon()
				let inactiveImage = inactiveIcon()
				let animation = CABasicAnimation(keyPath: "contents")
				animation.duration = 0.2
				animation.fromValue = isSelected ? activeImage.cgImage : inactiveImage.cgImage
				animation.toValue = isSelected ? inactiveImage.cgImage : activeImage.cgImage
				imageView?.layer.add(animation, forKey: "icon")
			}
			super.isSelected = newValue;
		}
	}

	@objc func touchUpInside()
	{
		guard let group = self.group else { return }
		group.setSelected(button: self)
	}

	private func activeIcon() -> UIImage
	{
		let image = activeImage ?? draw(selected: true)
		activeImage = image
		return image
	}

	private func inactiveIcon() -> UIImage
	{
		let image = inactiveImage ?? draw(selected: false)
		inactiveImage = image
		return image
	}

	private func draw(selected: Bool) -> UIImage
	{
		var image = UIImage()

		let defaultColor = titleColor(for: .normal) ?? UIColor.foregroundColor()
		let iconColor = self.iconColor ?? defaultColor
		let indicatorColor = self.indicatorColor ?? defaultColor

		let iconSize = CGSize(width: iconWidth, height: iconWidth)
		let indicatorSize = CGSize(width: 0.5 * iconWidth, height: 0.5 * iconWidth)
		let strokeWidth: CGFloat = 1.0

		UIGraphicsBeginImageContextWithOptions(iconSize, false, 0.0)

		var iconRect = CGRect.zero
		iconRect.origin.x = 0.5 * strokeWidth
		iconRect.origin.y = 0.5 * strokeWidth
		iconRect.size.width = iconSize.width - strokeWidth
		iconRect.size.height = iconSize.height - strokeWidth

		let iconPath = UIBezierPath(ovalIn: iconRect)
		iconPath.lineWidth = strokeWidth
		iconColor.setStroke()
		iconPath.stroke()

		if selected
		{
			var indicatorRect = CGRect.zero
			indicatorRect.origin.x = 0.5 * (iconSize.width - indicatorSize.width)
			indicatorRect.origin.y = 0.5 * (iconSize.height - indicatorSize.height)
			indicatorRect.size = indicatorSize

			let indicatorPath = UIBezierPath(ovalIn: indicatorRect)
			indicatorColor.setFill()
			indicatorPath.fill()
		}

		image = UIGraphicsGetImageFromCurrentImageContext() ?? image
		UIGraphicsPopContext()
		UIGraphicsEndImageContext()
		return image
	}
}
