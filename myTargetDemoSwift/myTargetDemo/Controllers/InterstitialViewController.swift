//
//  InterstitialViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 30/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

class InterstitialViewController: UIViewController, MTRGInterstitialAdDelegate
{
	var slotId: UInt?

	private var interstitialAd: MTRGInterstitialAd?
	private var notificationView: NotificationView?

	private let typeGroup = RadioButtonsGroup()

	@IBOutlet weak var radioButtonPromoStatic: RadioButton!
	@IBOutlet weak var radioButtonImage: RadioButton!
	@IBOutlet weak var radioButtonCarousel: RadioButton!
	@IBOutlet weak var radioButtonHtml: RadioButton!
	@IBOutlet weak var radioButtonPromoVideo: RadioButton!
	@IBOutlet weak var radioButtonVideo: RadioButton!
	@IBOutlet weak var radioButtonVast: RadioButton!
	@IBOutlet weak var radioButtonRewarded: RadioButton!


	@IBOutlet weak var loadButton: CustomButton!
	@IBOutlet weak var showButton: CustomButton!

    override func viewDidLoad()
	{
        super.viewDidLoad()

		navigationItem.title = "Interstitial"
		notificationView = NotificationView.create(view: view)
		notificationView?.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0

		showButton.isEnabled = false

		radioButtonPromoStatic.isSelected = true

		radioButtonPromoStatic.slot = Slot.intertitialPromo
		radioButtonImage.slot = Slot.intertitialImage
		radioButtonCarousel.slot = Slot.interstitialCards
		radioButtonHtml.slot = Slot.interstitialHtml
		radioButtonPromoVideo.slot = Slot.intertitialPromoVideo
		radioButtonVideo.slot = Slot.intertitialPromoVideoStyle
		radioButtonVast.slot = Slot.interstitialVast
		radioButtonRewarded.slot = Slot.intertitialRewardedVideo

		typeGroup.addButtons([radioButtonPromoStatic, radioButtonPromoVideo, radioButtonVideo, radioButtonVast, radioButtonImage, radioButtonCarousel, radioButtonHtml, radioButtonRewarded])
    }

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		notificationView?.view = view
	}

	private func defaultSlot() -> UInt
	{
		let slot = typeGroup.selectedButton?.slot ?? Slot.intertitialPromo
		return slot.rawValue
	}

	@IBAction func load(_ sender: CustomButton)
	{
		loadButton.isEnabled = false
		showButton.isEnabled = false
		let slotId = self.slotId ?? defaultSlot()
		interstitialAd = MTRGInterstitialAd(slotId: slotId)
		guard let interstitialAd = interstitialAd else { return }
		interstitialAd.delegate = self
		interstitialAd.load()
		notificationView?.showMessage("Loading...")
	}

	@IBAction func show(_ sender: CustomButton)
	{
		guard let interstitialAd = interstitialAd else { return }
		showButton.isEnabled = false
		interstitialAd.show(with: self)
	}

// MARK: - MTRGInterstitialAdDelegate

	func onLoad(with interstitialAd: MTRGInterstitialAd)
	{
		loadButton.isEnabled = true
		showButton.isEnabled = true
		notificationView?.showMessage("onLoad() called")
	}

	func onNoAd(withReason reason: String, interstitialAd: MTRGInterstitialAd)
	{
		loadButton.isEnabled = true
		showButton.isEnabled = false
		notificationView?.showMessage("onNoAd(\(reason)) called")
	}

	func onClick(with interstitialAd: MTRGInterstitialAd)
	{
		notificationView?.showMessage("onClick() called")
	}

	func onClose(with interstitialAd: MTRGInterstitialAd)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onClose() called")
	}

	func onVideoComplete(with interstitialAd: MTRGInterstitialAd)
	{
		notificationView?.showMessage("onVideoComplete() called")
	}

	func onDisplay(with interstitialAd: MTRGInterstitialAd)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onDisplay() called")
	}

	func onLeaveApplication(with interstitialAd: MTRGInterstitialAd)
	{
		notificationView?.showMessage("onLeaveApplication() called")
	}
}
