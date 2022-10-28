//
//  AlertMenu.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 05.09.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import MyTargetSDK

final class AlertMenuFactory: NSObject, MTRGMenuFactory {
	func menu() -> MTRGMenu {
		return AlertMenu()
	}
}

final class AlertMenu: NSObject, MTRGMenu {
	private var actions: [MTRGMenuAction] = []

	func add(menuAction action: MTRGMenuAction) {
		actions.append(action)
	}

	func present(in viewController: UIViewController, sourceView: UIView?) {
		let alert = UIAlertController(title: "AdChoices menu", message: nil, preferredStyle: .alert)

		actions.forEach { action in
			let alertAction = UIAlertAction(title: action.title, style: action.style.alertAction, handler: { _ in action.handleClick() })
			alert.addAction(alertAction)
		}

		viewController.present(alert, animated: true)
	}
}

extension MTRGMenuActionStyle {

	var alertAction: UIAlertAction.Style {
		switch self {
		case .default:
			return .default
		case .cancel:
			return .cancel
		@unknown default:
			return .default
		}
	}

}
