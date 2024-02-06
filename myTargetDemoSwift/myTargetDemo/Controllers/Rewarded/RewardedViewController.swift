//
//  RewardedViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 19.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class RewardedViewController: UIViewController {

    private let slotId: UInt?
    private let query: [String: String]?

    private lazy var notificationView: NotificationView = .create(view: view)
    private lazy var loadButton: CustomButton = .init(title: "Load")
    private lazy var showButton: CustomButton = {
        let button = CustomButton(title: "Show")
        button.isEnabled = false
        return button
    }()

    private var rewardedAd: MTRGRewardedAd?

    private let buttonHorizontalMargin: CGFloat = 16
    private let buttonInteritemSpace: CGFloat = 16
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

        navigationItem.title = "Rewarded video"

        view.backgroundColor = .backgroundColor()
        view.addSubview(loadButton)
        view.addSubview(showButton)

        loadButton.addTarget(self, action: #selector(loadButtonTap(_:)), for: .touchUpInside)
        showButton.addTarget(self, action: #selector(showButtonTap(_:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = view.safeAreaInsets
        let centerY = view.bounds.height / 2
        loadButton.frame = CGRect(x: safeAreaInsets.left + buttonHorizontalMargin,
                                  y: centerY - buttonInteritemSpace / 2 - buttonHeight,
                                  width: view.bounds.width - buttonHorizontalMargin * 2 - safeAreaInsets.left - safeAreaInsets.right,
                                  height: buttonHeight)
        showButton.frame = CGRect(x: safeAreaInsets.left + buttonHorizontalMargin,
                                  y: loadButton.frame.maxY + buttonInteritemSpace,
                                  width: view.bounds.width - buttonHorizontalMargin * 2 - safeAreaInsets.left - safeAreaInsets.right,
                                  height: buttonHeight)
    }

    // MARK: - Rewarded ad

    private func loadRewardedAd() {
        loadButton.isEnabled = false
        showButton.isEnabled = false

        rewardedAd = MTRGRewardedAd(slotId: slotId ?? Slot.rewardedVideo.id)
        rewardedAd?.delegate = self

        query?.forEach { rewardedAd?.customParams.setCustomParam($0.value, forKey: $0.key) }

        rewardedAd?.load()
        notificationView.showMessage("Loading...")
    }

    private func showRewardedAd() {
        guard let rewardedAd = rewardedAd else {
            return
        }

        showButton.isEnabled = false
        rewardedAd.show(with: self)
    }

    // MARK: - Actions

    @objc private func loadButtonTap(_ sender: CustomButton) {
        loadRewardedAd()
    }

    @objc private func showButtonTap(_ sender: CustomButton) {
        showRewardedAd()
    }

}

// MARK: - MTRGRewardedAdDelegate

extension RewardedViewController: MTRGRewardedAdDelegate {

    func onLoad(with rewardedAd: MTRGRewardedAd) {
        loadButton.isEnabled = true
        showButton.isEnabled = true
        notificationView.showMessage("onLoad() called")
    }

    func onLoadFailed(error: Error, rewardedAd: MTRGRewardedAd) {
        loadButton.isEnabled = true
        showButton.isEnabled = false
        notificationView.showMessage("onLoadFailed(\(error)) called")
    }

    func onClick(with rewardedAd: MTRGRewardedAd) {
        notificationView.showMessage("onClick() called")
    }

    func onClose(with rewardedAd: MTRGRewardedAd) {
        showButton.isEnabled = true
        notificationView.showMessage("onClose() called")
    }

    func onReward(_ reward: MTRGReward, rewardedAd: MTRGRewardedAd) {
        notificationView.showMessage("onReward(\(reward.type)) called")
    }

    func onDisplay(with rewardedAd: MTRGRewardedAd) {
        showButton.isEnabled = true
        notificationView.showMessage("onDisplay() called")
    }

    func onLeaveApplication(with rewardedAd: MTRGRewardedAd) {
        notificationView.showMessage("onLeaveApplication() called")
    }

}
