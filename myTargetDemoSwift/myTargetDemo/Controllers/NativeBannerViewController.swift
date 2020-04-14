//
//  NativeBannerViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 01/04/2020.
//  Copyright © 2020 Mail.Ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

class NativeBannerViewController: UIViewController, AdViewController, MTRGNativeBannerAdDelegate
{
	var slotId: UInt?

	private var nativeBannerAd: MTRGNativeBannerAd?
	private var notificationView: NotificationView?
	private var collectionController: CollectionViewController?

	@IBOutlet weak var showButton: CustomButton!

	override func viewDidLoad()
	{
        super.viewDidLoad()

		navigationItem.title = "Native Banner Ad"
		notificationView = NotificationView.create(view: view)
		notificationView?.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0
	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		notificationView?.view = view
	}

	private func createNativeBanner(_ banner: MTRGNativeBanner) -> UIView?
	{
		let nativeBannerAdView = MTRGNativeViewsFactory.createNativeBannerAdView()
		nativeBannerAdView.banner = banner

		let nativeAdContainer = MTRGNativeAdContainer.create(withAdView: nativeBannerAdView)
		nativeAdContainer.ageRestrictionsView = nativeBannerAdView.ageRestrictionsLabel
		nativeAdContainer.advertisingView = nativeBannerAdView.adLabel
		nativeAdContainer.iconView = nativeBannerAdView.iconAdView
		nativeAdContainer.domainView = nativeBannerAdView.domainLabel
		nativeAdContainer.disclaimerView = nativeBannerAdView.disclaimerLabel
		nativeAdContainer.ratingView = nativeBannerAdView.ratingStarsLabel
		nativeAdContainer.votesView = nativeBannerAdView.votesLabel
		nativeAdContainer.ctaView = nativeBannerAdView.buttonView
		nativeAdContainer.titleView = nativeBannerAdView.titleLabel

		return nativeAdContainer
	}

	@IBAction func show(_ sender: CustomButton)
	{
		showButton.isEnabled = false

		let slotId = self.slotId ?? Slot.nativeBanner.rawValue
		nativeBannerAd = MTRGNativeBannerAd(slotId: slotId)
		guard let nativeBannerAd = nativeBannerAd else { return }
		nativeBannerAd.delegate = self
		nativeBannerAd.load()
		notificationView?.showMessage("Loading...")
	}

	// MARK: - MTRGNativeBannerAdDelegate

	func onLoad(with banner: MTRGNativeBanner, nativeBannerAd: MTRGNativeBannerAd)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onLoad() called")

		collectionController = CollectionViewController()
		guard let collectionController = collectionController else { return }
		guard let adView = createNativeBanner(banner) else { return }

		nativeBannerAd.register(adView, with: collectionController)
		collectionController.adView = adView
		collectionController.adSize = CGSize(width: 300, height: 250)
		notificationView?.view = collectionController.view
		navigationController?.pushViewController(collectionController, animated: true)
	}

	func onNoAd(withReason reason: String, nativeBannerAd: MTRGNativeBannerAd)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onNoAd(\(reason)) called")
	}

	func onAdShow(with nativeBannerAd: MTRGNativeBannerAd)
	{
		notificationView?.showMessage("onAdShow() called")
	}

	func onAdClick(with nativeBannerAd: MTRGNativeBannerAd)
	{
		notificationView?.showMessage("onAdClick() called")
	}

	func onShowModal(with nativeBannerAd: MTRGNativeBannerAd)
	{
		notificationView?.showMessage("onShowModal() called")
	}

	func onDismissModal(with nativeBannerAd: MTRGNativeBannerAd)
	{
		notificationView?.showMessage("onDismissModal() called")
	}

	func onLeaveApplication(with nativeBannerAd: MTRGNativeBannerAd)
	{
		notificationView?.showMessage("onLeaveApplication() called")
	}
}
