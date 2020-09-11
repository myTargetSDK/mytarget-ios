//
//  RewardedViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 14.08.2020.
//  Copyright © 2020 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

class RewardedViewController: UIViewController, AdViewController, MTRGRewardedAdDelegate
{
	var slotId: UInt?

	private var rewardedAd: MTRGRewardedAd?
	private var notificationView: NotificationView?

	@IBOutlet weak var loadButton: CustomButton!
	@IBOutlet weak var showButton: CustomButton!

	override func viewDidLoad()
	{
		super.viewDidLoad()

		navigationItem.title = "Rewarded Video"
		notificationView = NotificationView.create(view: view)
		notificationView?.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0

		showButton.isEnabled = false
	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		notificationView?.view = view
	}

	private func defaultSlot() -> UInt
	{
		return Slot.rewardedVideo.rawValue
	}

	@IBAction func load(_ sender: CustomButton)
	{
		loadButton.isEnabled = false
		showButton.isEnabled = false
		let slotId = self.slotId ?? defaultSlot()
		rewardedAd = MTRGRewardedAd(slotId: slotId)
		guard let rewardedAd = rewardedAd else { return }
		rewardedAd.delegate = self
		rewardedAd.load()
		notificationView?.showMessage("Loading...")
	}

	@IBAction func show(_ sender: CustomButton)
	{
		guard let rewardedAd = rewardedAd else { return }
		showButton.isEnabled = false
		rewardedAd.show(with: self)
	}

// MARK: - MTRGRewardedAdDelegate

	func onLoad(with rewardedAd: MTRGRewardedAd)
	{
		loadButton.isEnabled = true
		showButton.isEnabled = true
		notificationView?.showMessage("onLoad() called")
	}

	func onNoAd(withReason reason: String, rewardedAd: MTRGRewardedAd)
	{
		loadButton.isEnabled = true
		showButton.isEnabled = false
		notificationView?.showMessage("onNoAd(\(reason)) called")
	}

	func onClick(with rewardedAd: MTRGRewardedAd)
	{
		notificationView?.showMessage("onClick() called")
	}

	func onClose(with rewardedAd: MTRGRewardedAd)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onClose() called")
	}

	func onReward(_ reward: MTRGReward, rewardedAd: MTRGRewardedAd)
	{
		notificationView?.showMessage("onReward(\(reward.type)) called")
	}

	func onDisplay(with rewardedAd: MTRGRewardedAd)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onDisplay() called")
	}

	func onLeaveApplication(with rewardedAd: MTRGRewardedAd)
	{
		notificationView?.showMessage("onLeaveApplication() called")
	}
}
