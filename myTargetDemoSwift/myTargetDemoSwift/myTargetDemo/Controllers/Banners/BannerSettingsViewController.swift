//
//  BannerSettingsViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 18.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class BannerSettingsViewController: UIViewController {

    private enum SizeRadioButtons: String, CaseIterable {
        case adaptiveAuto = "Adaptive (Auto)"
        case adaptiveManual = "Adaptive (Manual)"
        case banner320x50 = "320x50"
        case banner300x250 = "300x250"
        case banner728x90 = "728x90 (iPad only)"
    }

    private enum KindRadioButtons: String, CaseIterable {
        case bottomBanner = "Bottom banner"
        case bannerInsideCollectionView = "Banner inside collection view"
    }

    private let slotId: UInt?
    private let query: [String: String]?

    private lazy var sizeRadioButtons: RadioButtonsView<SizeRadioButtons> = {
        let radioButtons = RadioButtonsView<SizeRadioButtons>(title: "Size")
        if UIDevice.current.userInterfaceIdiom != .pad {
            radioButtons.changeEnabled(false, for: .banner728x90)
        }
        return radioButtons
    }()
    private lazy var kindRadioButtons: RadioButtonsView<KindRadioButtons> = .init(title: "Kind")
    private lazy var showButton: CustomButton = .init(title: "Show")

    private let radioButtonsInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 16, right: 16)
    private let showButtonInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    private let showButtonHeight: CGFloat = 40

    init(slotId: UInt? = nil, query: [String: String]? = nil) {
        self.slotId = slotId
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Banner settings"

        view.backgroundColor = .backgroundColor()
        view.addSubview(sizeRadioButtons)
        view.addSubview(kindRadioButtons)
        view.addSubview(showButton)

        showButton.addTarget(self, action: #selector(showButtonTap(_:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = view.safeAreaInsets
        let radioButtonsWidth = view.bounds.width - safeAreaInsets.left - safeAreaInsets.right - radioButtonsInsets.left - radioButtonsInsets.right

        let sizeRadioButtonsHeight = sizeRadioButtons.sizeThatFits(.init(width: radioButtonsWidth, height: .greatestFiniteMagnitude)).height
        sizeRadioButtons.frame = CGRect(x: safeAreaInsets.left + radioButtonsInsets.left,
                                        y: safeAreaInsets.top + radioButtonsInsets.top,
                                        width: radioButtonsWidth,
                                        height: sizeRadioButtonsHeight)

        let kindRadioButtonsHeight = kindRadioButtons.sizeThatFits(.init(width: radioButtonsWidth, height: .greatestFiniteMagnitude)).height
        kindRadioButtons.frame = CGRect(x: safeAreaInsets.left + radioButtonsInsets.left,
                                        y: sizeRadioButtons.frame.maxY + radioButtonsInsets.bottom + radioButtonsInsets.top,
                                        width: radioButtonsWidth,
                                        height: kindRadioButtonsHeight)

        let showButtonWidth = view.bounds.width - safeAreaInsets.left - safeAreaInsets.right - showButtonInsets.left - showButtonInsets.right
        showButton.frame = CGRect(x: safeAreaInsets.left + showButtonInsets.left,
                                  y: kindRadioButtons.frame.maxY + radioButtonsInsets.bottom + showButtonInsets.top,
                                  width: showButtonWidth,
                                  height: showButtonHeight)
    }

    // MARK: - Actions

    @objc private func showButtonTap(_ sender: CustomButton) {
        let slot: Slot.Standard
        let adSize: MTRGAdSize?

        switch sizeRadioButtons.selectedRadioButtonType {
        case .adaptiveAuto:
            slot = .bannerAdaptive
            adSize = nil
        case .adaptiveManual:
            slot = .bannerAdaptive
            adSize = .forCurrentOrientation()
        case .banner320x50:
            slot = .banner320x50
            adSize = .adSize320x50()
        case .banner300x250:
            slot = .banner300x250
            adSize = .adSize300x250()
        case .banner728x90:
            slot = .banner728x90
            adSize = .adSize728x90()
        }

        let slotId = slotId ?? slot.id
        let viewController: UIViewController

        switch kindRadioButtons.selectedRadioButtonType {
        case .bottomBanner:
            viewController = BottomBannerViewController(slotId: slotId, query: query, adSize: adSize)
        case .bannerInsideCollectionView:
            viewController = BannerViewController(slotId: slotId, query: query, adSize: adSize)
        }

        navigationController?.pushViewController(viewController, animated: true)
    }

}
