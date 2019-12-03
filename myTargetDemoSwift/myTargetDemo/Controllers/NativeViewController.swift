//
//  NativeViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 29/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

class NativeViewController: UIViewController, MTRGNativeAdDelegate, MTRGMediaAdViewDelegate
{
	var slotId: UInt?

	private var nativeAd: MTRGNativeAd?
	private var notificationView: NotificationView?
	private var collectionController: CollectionViewController?

	private let viewGroup = RadioButtonsGroup()
	private let typeGroup = RadioButtonsGroup()

	@IBOutlet weak var radioButtonContentStream: RadioButton!
	@IBOutlet weak var radioButtonContentWall: RadioButton!
	@IBOutlet weak var radioButtonNewsFeed: RadioButton!
	@IBOutlet weak var radioButtonChatList: RadioButton!

	@IBOutlet weak var radioButtonPromo: RadioButton!
	@IBOutlet weak var radioButtonVideo: RadioButton!
	@IBOutlet weak var radioButtonCarousel: RadioButton!

	@IBOutlet weak var showButton: CustomButton!
	
	override func viewDidLoad()
	{
        super.viewDidLoad()

		navigationItem.title = "Native ads"
		notificationView = NotificationView.create(view: view)
		notificationView?.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0

		radioButtonContentStream.isSelected = true
		radioButtonPromo.isSelected = true

		radioButtonPromo.slot = Slot.nativePromo
		radioButtonVideo.slot = Slot.nativeVideo
		radioButtonCarousel.slot = Slot.nativeCards

		viewGroup.addButtons([radioButtonContentStream, radioButtonContentWall, radioButtonNewsFeed, radioButtonChatList])
		typeGroup.addButtons([radioButtonPromo, radioButtonVideo, radioButtonCarousel])
    }

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		notificationView?.view = view
	}

	private func defaultSlot() -> UInt
	{
		let slot = typeGroup.selectedButton?.slot ?? Slot.nativePromo
		return slot.rawValue
	}

	private func createView(promoBanner: MTRGNativePromoBanner, loadImages: Bool) -> UIView?
	{
		var containerView: MTRGNativeAdContainer? = nil
		if radioButtonContentStream.isSelected
		{
			let contentStreamView = MTRGNativeViewsFactory.createContentStreamView(with: promoBanner)
			contentStreamView.mediaAdView.delegate = self
			if loadImages
			{
				contentStreamView.loadImages()
			}
			let nativeAdContainer = MTRGNativeAdContainer.create(withAdView: contentStreamView)
			nativeAdContainer.ageRestrictionsView = contentStreamView.ageRestrictionsLabel
			nativeAdContainer.advertisingView = contentStreamView.adLabel
			nativeAdContainer.titleView = contentStreamView.titleLabel
			nativeAdContainer.descriptionView = contentStreamView.descriptionLabel
			nativeAdContainer.iconView = contentStreamView.iconImageView
			nativeAdContainer.mediaView = contentStreamView.mediaAdView
			nativeAdContainer.domainView = contentStreamView.domainLabel
			nativeAdContainer.categoryView = contentStreamView.categoryLabel
			nativeAdContainer.disclaimerView = contentStreamView.disclaimerLabel
			nativeAdContainer.ratingView = contentStreamView.ratingStarsLabel
			nativeAdContainer.votesView = contentStreamView.votesLabel
			nativeAdContainer.ctaView = contentStreamView.buttonView
			containerView = nativeAdContainer
		}
		else if radioButtonContentWall.isSelected
		{
			let contentWallView = MTRGNativeViewsFactory.createContentWallView(with: promoBanner)
			contentWallView.mediaAdView.delegate = self
			if loadImages
			{
				contentWallView.loadImages()
			}
			let nativeAdContainer = MTRGNativeAdContainer.create(withAdView: contentWallView)
			nativeAdContainer.ageRestrictionsView = contentWallView.ageRestrictionsLabel
			nativeAdContainer.advertisingView = contentWallView.adLabel
			nativeAdContainer.mediaView = contentWallView.mediaAdView
			containerView = nativeAdContainer
		}
		else if radioButtonNewsFeed.isSelected
		{
			let newsFeedView = MTRGNativeViewsFactory.createNewsFeedView(with: promoBanner)
			if loadImages
			{
				newsFeedView.loadImages()
			}
			let nativeAdContainer = MTRGNativeAdContainer.create(withAdView: newsFeedView)
			nativeAdContainer.ageRestrictionsView = newsFeedView.ageRestrictionsLabel
			nativeAdContainer.advertisingView = newsFeedView.adLabel
			nativeAdContainer.iconView = newsFeedView.iconImageView
			nativeAdContainer.domainView = newsFeedView.domainLabel
			nativeAdContainer.categoryView = newsFeedView.categoryLabel
			nativeAdContainer.disclaimerView = newsFeedView.disclaimerLabel
			nativeAdContainer.ratingView = newsFeedView.ratingStarsLabel
			nativeAdContainer.votesView = newsFeedView.votesLabel
			nativeAdContainer.ctaView = newsFeedView.buttonView
			nativeAdContainer.titleView = newsFeedView.titleLabel
			containerView = nativeAdContainer
		}
		else if radioButtonChatList.isSelected
		{
			let chatListView = MTRGNativeViewsFactory.createChatListView(with: promoBanner)
			if loadImages
			{
				chatListView.loadImages()
			}
			let nativeAdContainer = MTRGNativeAdContainer.create(withAdView: chatListView)
			nativeAdContainer.ageRestrictionsView = chatListView.ageRestrictionsLabel
			nativeAdContainer.advertisingView = chatListView.adLabel
			nativeAdContainer.titleView = chatListView.titleLabel
			nativeAdContainer.descriptionView = chatListView.descriptionLabel
			nativeAdContainer.iconView = chatListView.iconImageView
			nativeAdContainer.domainView = chatListView.domainLabel
			nativeAdContainer.disclaimerView = chatListView.disclaimerLabel
			nativeAdContainer.ratingView = chatListView.ratingStarsLabel
			nativeAdContainer.votesView = chatListView.votesLabel
			containerView = nativeAdContainer
		}
		return containerView
	}

	@IBAction func show(_ sender: CustomButton)
	{
		showButton.isEnabled = false
		let slotId = self.slotId ?? defaultSlot()
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
		guard let adView = createView(promoBanner: promoBanner, loadImages: !nativeAd.autoLoadImages) else { return }

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
