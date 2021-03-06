//
//  NotificationView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 23/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

enum NotificationAlignment
{
	case top
	case center
	case bottom
}

class NotificationView: UIView
{
	weak var view: UIView?
	{
		didSet
		{
			guard isActive else { return }
			isActive = false
			self.removeFromSuperview()
			appear()
		}
	}
	var alignment = NotificationAlignment.top
	var navigationBarHeight: CGFloat = 0.0

	private var messages = [String]()
	private let label = UILabel()
	private let margins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
	private var cachedSize = CGSize.zero
	private var safeArea: UIEdgeInsets
	{
		var safeArea = UIEdgeInsets.zero
		let statusBarSize = UIApplication.shared.statusBarFrame.size
		let statusBarHeight = min(statusBarSize.width, statusBarSize.height)
		safeArea.top = statusBarHeight + navigationBarHeight

		if #available(iOS 11.0, *), let view = view
		{
			safeArea = view.safeAreaInsets
		}

		return safeArea
	}
	private var isActive = false
	private var timer: Timer?

	static func create(view: UIView) -> NotificationView
	{
		let notificationView = NotificationView()
		notificationView.view = view
		return notificationView
	}

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

	private func configure()
	{
		alpha = 0.0
		layer.cornerRadius = 4.0
		label.numberOfLines = 0
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 14)
		label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(label)
		applyColors()
	}

	private func applyColors()
	{
		label.textColor = UIColor.backgroundColor()
		backgroundColor = UIColor.foregroundColor().withAlphaComponent(0.85)
	}

	override func tintColorDidChange()
	{
		super.tintColorDidChange()
		applyColors()
	}

	override func layoutSubviews()
	{
		super.layoutSubviews()
		guard let view = view, cachedSize != view.frame.size else { return }
		cachedSize = view.frame.size
		adjustFrame()
	}

	public func showMessage(_ message: String)
	{
		print("Log message: \(message)")
		messages.append(String(message.prefix(256)))
		if !isActive
		{
			appear()
		}
		else
		{
			timerStart(interval: 0.5)
		}
	}

	private func adjustFrame()
	{
		guard let view = view else { return }

		let labelWidth = view.frame.width - (margins.left + margins.right)
		var toSize = label.sizeThatFits(CGSize(width: labelWidth, height: view.frame.height))
		toSize.width += margins.left + margins.right
		toSize.height += margins.top + margins.bottom

		var fromPoint = view.center
		var toPoint = CGPoint.zero
		toPoint.x = 0.5 * (view.frame.width - toSize.width)
		toPoint.y = 0.5 * (view.frame.height - toSize.height)

		let safeArea = self.safeArea

		switch alignment
		{
			case .top:
				fromPoint.y = safeArea.top
				toPoint.y = safeArea.top
				break
			case .bottom:
				fromPoint.y = view.frame.height - safeArea.bottom
				toPoint.y = view.frame.height - safeArea.bottom - toSize.height
				break
			default:
				break
		}

		if !isActive
		{
			frame = CGRect(origin: fromPoint, size: .zero)
		}
		animate(toPoint: toPoint, size: toSize, alpha: 1.0)
	}

	private func appear()
	{
		guard let view = view, !messages.isEmpty, let message = messages.first else { return }
		label.text = message

		if !isActive
		{
			isActive = true
			view.addSubview(self)
		}
		adjustFrame()
		timerStart()
	}

	private func disapper()
	{
		timerStop()
		var toPoint = CGPoint.zero
		switch alignment
		{
			case .top:
				toPoint.x = center.x
				toPoint.y = frame.origin.y
				break
			case .bottom:
				toPoint.x = center.x
				toPoint.y = frame.origin.y + frame.height
				break
			default:
				toPoint = center
		}
		animate(toPoint: toPoint, size: .zero, alpha: 0.0)
		{
			self.isActive = false
			self.label.text = nil
			self.removeFromSuperview()
		}
	}

	private func animate(toPoint point: CGPoint, size: CGSize, alpha: CGFloat, completion: (() -> Void)? = nil)
	{
		UIView.animate(withDuration: 0.3, animations:
		{
			self.frame = CGRect(origin: point, size: size)
			self.alpha = alpha
		})
		{ success in
			completion?()
		}
	}

	private func timerStart(interval: TimeInterval = 1.0)
	{
		timerStop()
		timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
	}

	private func timerStop()
	{
		if let timer = timer, timer.isValid
		{
			timer.invalidate()
		}
		timer = nil
	}

	@objc private func fireTimer()
	{
		messages.removeFirst()
		if messages.isEmpty
		{
			disapper()
		}
		else
		{
			appear()
		}
	}
}
