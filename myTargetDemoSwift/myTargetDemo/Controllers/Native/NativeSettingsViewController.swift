//
//  NativeSettingsViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 18.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

final class NativeSettingsViewController: UIViewController {

    private enum ViewRadioButtons: String, CaseIterable {
        case promo = "Promo"
        case video = "Video"
        case cards = "Cards"
    }

	private enum KindRadioButtons: String, CaseIterable {
		case nativeInsideCollectionView = "inside collection view"
		case nativeCustomAdChoices = "custom adChoices (drawingManual)"
		case nativeCloseManually = "close manually"
	}

    private lazy var viewRadioButtons: RadioButtonsView<ViewRadioButtons> = .init(title: "View type")
	private lazy var kindRadioButtons: RadioButtonsView<KindRadioButtons> = .init(title: "Kind")
    private lazy var showButton: CustomButton = .init(title: "Show")

    private let radioButtonsInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 16, right: 16)
    private let showButtonInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    private let buttonHeight: CGFloat = 40

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Native Ads settings"

        view.backgroundColor = .backgroundColor()
        view.addSubview(viewRadioButtons)
		view.addSubview(kindRadioButtons)
        view.addSubview(showButton)

        showButton.addTarget(self, action: #selector(showButtonTap(_:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = view.safeAreaInsets
        let horizontalSafeArea = safeAreaInsets.left + safeAreaInsets.right

		let radioButtonsWidth = view.bounds.width - horizontalSafeArea - radioButtonsInsets.left - radioButtonsInsets.right

		let viewRadioButtonsHeight = viewRadioButtons.sizeThatFits(.init(width: radioButtonsWidth, height: .greatestFiniteMagnitude)).height
		viewRadioButtons.frame = CGRect(x: safeAreaInsets.left + radioButtonsInsets.left,
										y: safeAreaInsets.top + radioButtonsInsets.top,
										width: radioButtonsWidth,
										height: viewRadioButtonsHeight)

		let kindRadioButtonsHeight = kindRadioButtons.sizeThatFits(.init(width: radioButtonsWidth, height: .greatestFiniteMagnitude)).height
		kindRadioButtons.frame = CGRect(x: safeAreaInsets.left + radioButtonsInsets.left,
										y: viewRadioButtons.frame.maxY + radioButtonsInsets.bottom + radioButtonsInsets.top,
										width: radioButtonsWidth,
										height: kindRadioButtonsHeight)

        showButton.frame = CGRect(x: safeAreaInsets.left + showButtonInsets.left,
                                  y: kindRadioButtons.frame.maxY + radioButtonsInsets.bottom + showButtonInsets.top,
                                  width: view.bounds.width - horizontalSafeArea - showButtonInsets.left - showButtonInsets.right,
                                  height: buttonHeight)
    }

    // MARK: - Actions

    @objc private func showButtonTap(_ sender: CustomButton) {
        let slot: Slot
        switch viewRadioButtons.selectedRadioButtonType {
        case .promo:
            slot = Slot.nativePromo
        case .video:
            slot = Slot.nativeVideo
        case .cards:
            slot = Slot.nativeCards
        }

		let viewController: UIViewController
		switch kindRadioButtons.selectedRadioButtonType {
		case .nativeInsideCollectionView:
			viewController = NativeViewController(slotId: slot.id)
		case .nativeCustomAdChoices:
			viewController = NativeDrawingManualViewController(slotId: slot.id)
		case .nativeCloseManually:
			viewController = NativeCloseManuallyViewController(slotId: slot.id)
		}

        navigationController?.pushViewController(viewController, animated: true)
    }

}
