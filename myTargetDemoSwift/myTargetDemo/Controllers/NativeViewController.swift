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

	private var nativeAd: MTRGNativeAd?
	private var notificationView: NotificationView?
	private var collectionController: CollectionViewController?

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

		let slot = viewTypeGroup.selectedButton?.slot ?? Slot.nativePromo
		let slotId = self.slotId ?? slot.rawValue
		nativeAd = MTRGNativeAd(slotId: slotId)
		guard let nativeAd = nativeAd else { return }
		nativeAd.delegate = self
		nativeAd.load()
		notificationView?.showMessage("Loading...")
	}

// MARK: - MTRGMediaAdViewDelegate

	func onImageSizeChanged(_ mediaAdView: MTRGMediaAdView)
	{
		collectionController?.collectionView.reloadData()
		collectionController?.collectionView.collectionViewLayout.invalidateLayout()
	}

// MARK: - MTRGNativeAdDelegate

	func onLoad(with promoBanner: MTRGNativePromoBanner, nativeAd: MTRGNativeAd)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onLoad() called")

		collectionController = CollectionViewController()
		guard let collectionController = collectionController else { return }
		guard let adView = createNativeView(promoBanner) else { return }

		nativeAd.register(adView, with: collectionController)
		collectionController.adView = adView
		collectionController.adSize = CGSize(width: 300, height: 250)
		notificationView?.view = collectionController.view
		navigationController?.pushViewController(collectionController, animated: true)
	}

	func onNoAd(withReason reason: String, nativeAd: MTRGNativeAd)
	{
		showButton.isEnabled = true
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
