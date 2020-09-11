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

	private var nativeBannerAds = [MTRGNativeBannerAd]()
	private var nativeBannerAdLoader: MTRGNativeBannerAdLoader?
	private var nativeBannerViews = [UIView]()
	private var notificationView: NotificationView?
	private let collectionController = CollectionViewController()

	@IBOutlet weak var showButton: CustomButton!

	override func viewDidLoad()
	{
        super.viewDidLoad()

		navigationItem.title = "Native Banner Ad"
		notificationView = NotificationView.create(view: view)
		notificationView?.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0
		
		collectionController.adViewController = self
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
		refresh()
		notificationView?.view = collectionController.view
		navigationController?.pushViewController(collectionController, animated: true)
	}

	func refresh()
	{
		let slotId = self.slotId ?? Slot.nativeBanner.rawValue
		let nativeBannerAdLoader = MTRGNativeBannerAdLoader.init(forCount: 3, slotId: slotId)
		self.nativeBannerAdLoader = nativeBannerAdLoader

		nativeBannerAds.removeAll()
		nativeBannerViews.removeAll()
		notificationView?.showMessage("Loading...")

		nativeBannerAdLoader.load { (nativeBannerAds: [MTRGNativeBannerAd]) in
			self.notificationView?.showMessage("Loaded \(nativeBannerAds.count) ads")
			self.nativeBannerAds = nativeBannerAds
			for nativeBannerAd in nativeBannerAds
			{
				if let banner = nativeBannerAd.banner, let adView = self.createNativeBanner(banner)
				{
					self.nativeBannerViews.append(adView)
					nativeBannerAd.register(adView, with: self.collectionController)
				}
			}
			self.collectionController.adViews = self.nativeBannerViews
		}
	}

	func loadMore()
	{
		let slotId = self.slotId ?? Slot.nativeBanner.rawValue
		let nativeBannerAd = MTRGNativeBannerAd(slotId: slotId)
		nativeBannerAd.delegate = self
		nativeBannerAd.load()
		nativeBannerAds.append(nativeBannerAd)
		notificationView?.showMessage("Loading...")
	}

	func supportsInfiniteScroll() -> Bool
	{
		return true
	}

	// MARK: - MTRGNativeBannerAdDelegate

	func onLoad(with banner: MTRGNativeBanner, nativeBannerAd: MTRGNativeBannerAd)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onLoad() called")

		if let adView = createNativeBanner(banner)
		{
			nativeBannerViews.append(adView)
			nativeBannerAd.register(adView, with: collectionController)
		}
		collectionController.adViews = nativeBannerViews
	}

	func onNoAd(withReason reason: String, nativeBannerAd: MTRGNativeBannerAd)
	{
		notificationView?.showMessage("onNoAd(\(reason)) called")
		collectionController.adViews = nativeBannerViews
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
