//
//  NativeViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 29/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

class NativeViewController: UIViewController, AdViewController, MTRGNativeAdDelegate, MTRGMediaAdViewDelegate
{
	var slotId: UInt?

	private var nativeAds = [MTRGNativeAd]()
	private var nativeAdLoader: MTRGNativeAdLoader?
	private var nativeViews = [UIView]()
	private var notificationView: NotificationView?
	private let collectionController = CollectionViewController()

	private let viewTypeGroup = RadioButtonsGroup()

	@IBOutlet weak var radioButtonPromo: RadioButton!
	@IBOutlet weak var radioButtonVideo: RadioButton!
	@IBOutlet weak var radioButtonCards: RadioButton!

	@IBOutlet weak var showButton: CustomButton!

	override func viewDidLoad()
	{
        super.viewDidLoad()

		navigationItem.title = "Native Ad"
		notificationView = NotificationView.create(view: view)
		notificationView?.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0

		collectionController.adViewController = self

		radioButtonPromo.slot = Slot.nativePromo
		radioButtonVideo.slot = Slot.nativeVideo
		radioButtonCards.slot = Slot.nativeCards

		radioButtonPromo.isSelected = true
		viewTypeGroup.addButtons([radioButtonPromo, radioButtonVideo, radioButtonCards])
	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		notificationView?.view = view
	}

	private func createNativeView(_ promoBanner: MTRGNativePromoBanner) -> UIView?
	{
		let nativeAdView = MTRGNativeViewsFactory.createNativeAdView()
		nativeAdView.banner = promoBanner
		nativeAdView.mediaAdView.delegate = self

		let nativeAdContainer = MTRGNativeAdContainer.create(withAdView: nativeAdView)
		nativeAdContainer.ageRestrictionsView = nativeAdView.ageRestrictionsLabel
		nativeAdContainer.advertisingView = nativeAdView.adLabel
		nativeAdContainer.titleView = nativeAdView.titleLabel
		nativeAdContainer.descriptionView = nativeAdView.descriptionLabel
		nativeAdContainer.iconView = nativeAdView.iconAdView
		nativeAdContainer.mediaView = nativeAdView.mediaAdView
		nativeAdContainer.domainView = nativeAdView.domainLabel
		nativeAdContainer.categoryView = nativeAdView.categoryLabel
		nativeAdContainer.disclaimerView = nativeAdView.disclaimerLabel
		nativeAdContainer.ratingView = nativeAdView.ratingStarsLabel
		nativeAdContainer.votesView = nativeAdView.votesLabel
		nativeAdContainer.ctaView = nativeAdView.buttonView

		return nativeAdContainer
	}

	@IBAction func show(_ sender: CustomButton)
	{
		showButton.isEnabled = false
		refresh()
		notificationView?.view = collectionController.view
		navigationController?.pushViewController(collectionController, animated: true)
	}

	func refresh()
	{
		let slot = viewTypeGroup.selectedButton?.slot ?? Slot.nativePromo
		let slotId = self.slotId ?? slot.rawValue
		let nativeAdLoader = MTRGNativeAdLoader.init(forCount: 3, slotId: slotId)
		self.nativeAdLoader = nativeAdLoader

		nativeAds.removeAll()
		nativeViews.removeAll()
		notificationView?.showMessage("Loading...")

		nativeAdLoader.load { (nativeAds: [MTRGNativeAd]) in
			self.notificationView?.showMessage("Loaded \(nativeAds.count) ads")
			self.nativeAds = nativeAds
			for nativeAd in nativeAds
			{
				if let banner = nativeAd.banner, let adView = self.createNativeView(banner)
				{
					self.nativeViews.append(adView)
					nativeAd.register(adView, with: self.collectionController)
				}
			}
			self.collectionController.adViews = self.nativeViews
		}
	}

	func loadMore()
	{
		let slot = viewTypeGroup.selectedButton?.slot ?? Slot.nativePromo
		let slotId = self.slotId ?? slot.rawValue
		let nativeAd = MTRGNativeAd(slotId: slotId)
		nativeAd.delegate = self
		nativeAd.load()
		nativeAds.append(nativeAd)
		notificationView?.showMessage("Loading...")
	}
	
	func supportsInfiniteScroll() -> Bool
	{
		return true
	}

// MARK: - MTRGMediaAdViewDelegate

	func onImageSizeChanged(_ mediaAdView: MTRGMediaAdView)
	{
		collectionController.collectionView.reloadData()
		collectionController.collectionView.collectionViewLayout.invalidateLayout()
	}

// MARK: - MTRGNativeAdDelegate

	func onLoad(with promoBanner: MTRGNativePromoBanner, nativeAd: MTRGNativeAd)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onLoad() called")

		if let adView = createNativeView(promoBanner)
		{
			nativeViews.append(adView)
			nativeAd.register(adView, with: collectionController)
		}
		collectionController.adViews = nativeViews
	}

	func onNoAd(withReason reason: String, nativeAd: MTRGNativeAd)
	{
		showButton.isEnabled = true
		collectionController.adViews = nativeViews
		notificationView?.showMessage("onNoAd(\(reason)) called")
	}

	func onAdShow(with nativeAd: MTRGNativeAd)
	{
		notificationView?.showMessage("onAdShow() called")
	}

	func onAdClick(with nativeAd: MTRGNativeAd)
	{
		notificationView?.showMessage("onAdClick() called")
	}

	func onShowModal(with nativeAd: MTRGNativeAd)
	{
		notificationView?.showMessage("onShowModal() called")
	}

	func onDismissModal(with nativeAd: MTRGNativeAd)
	{
		notificationView?.showMessage("onDismissModal() called")
	}

	func onLeaveApplication(with nativeAd: MTRGNativeAd)
	{
		notificationView?.showMessage("onLeaveApplication() called")
	}

	func onVideoPlay(with nativeAd: MTRGNativeAd)
	{
		notificationView?.showMessage("onVideoPlay() called")
	}

	func onVideoPause(with nativeAd: MTRGNativeAd)
	{
		notificationView?.showMessage("onVideoPause() called")
	}

	func onVideoComplete(with nativeAd: MTRGNativeAd)
	{
		notificationView?.showMessage("onVideoComplete() called")
	}

}
