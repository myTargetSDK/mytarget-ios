//
//  InterstitialViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 19.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class InterstitialViewController: UIViewController {

    private enum RadioButtons: String, CaseIterable {
        case promoStatic = "Promo static"
        case image = "Image"
        case carousel = "Carousel"
        case html = "HTML"
        case promoVideo = "Promo video"
        case videoStyle = "Video style"
        case vastVideo = "VAST video"
        case rewardedVideo = "Rewarded video"
    }

    private let slotId: UInt?
    private let query: [String: String]?

    private lazy var radioButtons: RadioButtonsView<RadioButtons> = .init(title: "Type")
    private lazy var notificationView: NotificationView = .create(view: view)
    private lazy var loadButton: CustomButton = .init(title: "Load")
    private lazy var showButton: CustomButton = {
        let button = CustomButton(title: "Show")
        button.isEnabled = false
        return button
    }()

    private var interstitialAd: MTRGInterstitialAd?

    private let radioButtonsInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    private let buttonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: 16)
    private let buttonHeight: CGFloat = 40

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

        navigationItem.title = "Interstitial Ads"

        view.backgroundColor = .backgroundColor()
        view.addSubview(radioButtons)
        view.addSubview(loadButton)
        view.addSubview(showButton)

        loadButton.addTarget(self, action: #selector(loadButtonTap(_:)), for: .touchUpInside)
        showButton.addTarget(self, action: #selector(showButtonTap(_:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = view.safeAreaInsets
        let horizontalSafeArea = safeAreaInsets.left + safeAreaInsets.right

        if slotId == nil {
            let radioButtonsWidth = view.bounds.width - horizontalSafeArea - radioButtonsInsets.left - radioButtonsInsets.right
            let radioButtonsHeight = radioButtons.sizeThatFits(.init(width: radioButtonsWidth, height: .greatestFiniteMagnitude)).height
            radioButtons.frame = CGRect(x: safeAreaInsets.left + radioButtonsInsets.left,
                                        y: safeAreaInsets.top + radioButtonsInsets.top,
                                        width: radioButtonsWidth,
                                        height: radioButtonsHeight)

            loadButton.frame = CGRect(x: safeAreaInsets.left + buttonInsets.left,
                                      y: radioButtons.frame.maxY + radioButtonsInsets.bottom + buttonInsets.top,
                                      width: view.bounds.width - horizontalSafeArea - buttonInsets.left - buttonInsets.right,
                                      height: buttonHeight)

            showButton.frame = CGRect(x: safeAreaInsets.left + buttonInsets.left,
                                      y: loadButton.frame.maxY + buttonInsets.bottom + buttonInsets.top,
                                      width: view.bounds.width - horizontalSafeArea - buttonInsets.left - buttonInsets.right,
                                      height: buttonHeight)
        } else {
            let centerY = view.bounds.height / 2
            loadButton.frame = CGRect(x: safeAreaInsets.left + buttonInsets.left,
                                      y: centerY - buttonInsets.top / 2 - buttonHeight,
                                      width: view.bounds.width - buttonInsets.left - buttonInsets.right - horizontalSafeArea,
                                      height: buttonHeight)
            showButton.frame = CGRect(x: safeAreaInsets.left + buttonInsets.left,
                                      y: loadButton.frame.maxY + buttonInsets.top + buttonInsets.bottom,
                                      width: view.bounds.width - buttonInsets.left - buttonInsets.right - horizontalSafeArea,
                                      height: buttonHeight)
        }
    }

    // MARK: - Interstitial ad

    private func loadInterstitialAd() {
        loadButton.isEnabled = false
        showButton.isEnabled = false

        interstitialAd = MTRGInterstitialAd(slotId: slotId ?? defaultSlot().id)
        interstitialAd?.delegate = self

        query?.forEach { interstitialAd?.customParams.setCustomParam($0.value, forKey: $0.key) }

        interstitialAd?.load()
        notificationView.showMessage("Loading...")
    }

    private func showInterstitialAd() {
        guard let interstitialAd = interstitialAd else {
            return
        }

        showButton.isEnabled = false
        interstitialAd.show(with: self)
    }

    private func defaultSlot() -> Slot {
        switch radioButtons.selectedRadioButtonType {
        case .promoStatic:
            return .intertitialPromo
        case .image:
            return . intertitialImage
        case .carousel:
            return .interstitialCards
        case .html:
            return .interstitialHtml
        case .promoVideo:
            return .intertitialPromoVideo
        case .videoStyle:
            return .intertitialPromoVideoStyle
        case .vastVideo:
            return .interstitialVast
        case .rewardedVideo:
            return .intertitialRewardedVideo
        }
    }

    // MARK: - Actions

    @objc private func loadButtonTap(_ sender: CustomButton) {
        loadInterstitialAd()
    }

    @objc private func showButtonTap(_ sender: CustomButton) {
        showInterstitialAd()
    }

}

// MARK: - MTRGInterstitialAdDelegate

extension InterstitialViewController: MTRGInterstitialAdDelegate {

    func onLoad(with interstitialAd: MTRGInterstitialAd) {
        loadButton.isEnabled = true
        showButton.isEnabled = true
        notificationView.showMessage("onLoad() called")
    }

    func onLoadFailed(error: Error, interstitialAd: MTRGInterstitialAd) {
        loadButton.isEnabled = true
        showButton.isEnabled = false
        notificationView.showMessage("onLoadFailed(\(error)) called")
    }

    func onClick(with interstitialAd: MTRGInterstitialAd) {
        notificationView.showMessage("onClick() called")
    }

    func onClose(with interstitialAd: MTRGInterstitialAd) {
        showButton.isEnabled = true
        notificationView.showMessage("onClose() called")
    }

    func onVideoComplete(with interstitialAd: MTRGInterstitialAd) {
        notificationView.showMessage("onVideoComplete() called")
    }

    func onDisplay(with interstitialAd: MTRGInterstitialAd) {
        showButton.isEnabled = true
        notificationView.showMessage("onDisplay() called")
    }

    func onLeaveApplication(with interstitialAd: MTRGInterstitialAd) {
        notificationView.showMessage("onLeaveApplication() called")
    }

}
