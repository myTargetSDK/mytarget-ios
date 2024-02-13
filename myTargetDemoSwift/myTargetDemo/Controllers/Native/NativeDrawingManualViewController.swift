//
//  NativeDrawingManualViewController.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 05.10.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

/// This ViewController demonstrates how to work with `MTRGAdChoicesPlacementDrawingManual` placement.
/// This option enables to control AdChoicesView yourself.
/// You should add your AdChoices view and place it manually.
/// SDK provides AdChoices icon, which you can use for your AdChoices view (see `MTRGNativeBanner`).
/// Remember: if `cachePolicy` set to none or video, SDK will download AdChoices image asynchronously.
/// And you can get downloaded image in mediaDelegate's `onAdChoicesIconLoad(with:)` method.
/// if `cachePolicy` set to all or image, SDK will download AdChoices image along with ad.
/// You also should to notify SDK, when your AdChoices view has been clicked, via `handleAdChoicesClick(with:sourceView:)`
/// You can customize menu, that presents AdChoices options (see `MTRGMenuFactory` and `MTRGMenu`)

final class NativeDrawingManualViewController: UIViewController {

	private let slotId: UInt
	private let query: [String: String]?

	private lazy var notificationView: NotificationView = .create(view: view)
	private lazy var reloadButton: CustomButton = .init(title: "Reload")

	private let adViewMaxSize: CGSize = .init(width: 300, height: 250)
	private let reloadButtonInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 16, right: 16)
	private let buttonHeight: CGFloat = 40
	private let adChoicesRightOffset: CGFloat = 16
	private let adChoicesTopOffset: CGFloat = 8
	private let adChoicesMaxWidth: CGFloat = 24

	private var isLoading: Bool = false {
		didSet {
			reloadButton.isEnabled = !isLoading
		}
	}

	// Current ad
	private var adContainerView: UIView?
	private var adChoicesView: MTRGAdChoicesView?
	private var nativeAd: MTRGNativeAd?

	init(slotId: UInt, query: [String: String]? = nil) {
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

		navigationItem.title = "Native Ads"

		reloadButton.addTarget(self, action: #selector(reloadTapped(_:)), for: .touchUpInside)

		view.backgroundColor = .backgroundColor()
		view.addSubview(reloadButton)

		loadAd()
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

        let safeAreaInsets = view.safeAreaInsets

		if let adContainerView = adContainerView {
			let adContainerSize = adContainerView.sizeThatFits(adViewMaxSize)
			adContainerView.frame = CGRect(x: view.bounds.width / 2 - adContainerSize.width / 2,
										   y: view.bounds.height / 2 - adContainerSize.height / 2,
										   width: adContainerSize.width,
										   height: adContainerSize.height)

			if let adChoicesView = adChoicesView, let adChoicesSize = nativeAd?.banner?.adChoicesIcon?.size {
				let newSize = adChoicesSize.resize(targetSize: CGSize(width: adChoicesMaxWidth, height: CGFloat.greatestFiniteMagnitude))
				adChoicesView.frame = CGRect(x: adContainerView.bounds.width - adChoicesRightOffset - newSize.width,
											 y: adChoicesTopOffset,
											 width: newSize.width,
											 height: newSize.height)
			}
		}

		reloadButton.frame = CGRect(x: safeAreaInsets.left + reloadButtonInsets.left,
									y: view.bounds.height - safeAreaInsets.bottom - reloadButtonInsets.bottom - buttonHeight,
									width: view.bounds.width - safeAreaInsets.left - safeAreaInsets.right - reloadButtonInsets.left - reloadButtonInsets.right,
									height: buttonHeight)
	}

	private func loadAd() {
		let nativeAd = MTRGNativeAd(slotId: slotId, adChoicesMenuFactory: AlertMenuFactory())
		query?.forEach { nativeAd.customParams.setCustomParam($0.value, forKey: $0.key) }
		nativeAd.delegate = self
		nativeAd.mediaDelegate = self
		nativeAd.adChoicesPlacement = MTRGAdChoicesPlacementDrawingManual
		nativeAd.cachePolicy = MTRGCachePolicyNone // Load ad's images asynchronously
		nativeAd.load()

		self.nativeAd = nativeAd
		isLoading = true
		notificationView.showMessage("Loading...")
	}

	private func cleanup() {
		nativeAd?.unregisterView()
		nativeAd = nil

		adContainerView?.removeFromSuperview()
		adContainerView = nil
		adChoicesView = nil
	}

	func render(nativeAd: MTRGNativeAd) {
		isLoading = false

		guard let promoBanner = nativeAd.banner else {
			notificationView.showMessage("No banner info")
			return
		}

		let nativeAdContainer = createNativeView(from: promoBanner)
		let adChoicesView = createAdChoicesView()
		nativeAdContainer.addSubview(adChoicesView)

		nativeAd.register(nativeAdContainer, with: self)

		self.adContainerView = nativeAdContainer
		self.adChoicesView = adChoicesView

		view.addSubview(nativeAdContainer)
	}

	private func createNativeView(from promoBanner: MTRGNativePromoBanner?) -> UIView {
		let nativeAdView = MTRGNativeViewsFactory.createNativeAdView()
		nativeAdView.banner = promoBanner

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

	private func createAdChoicesView() -> MTRGAdChoicesView {
		let adChoicesView = MTRGNativeViewsFactory.createAdChoicesView()
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(adChoicesTapped(_:)))

		adChoicesView.addGestureRecognizer(tapGestureRecognizer)

		return adChoicesView
	}

	// MARK: - Actions

	@objc private func adChoicesTapped(_ sender: UITapGestureRecognizer) {
		guard let nativeAd = nativeAd else {
			return
		}

		nativeAd.handleAdChoicesClick(controller: self, sourceView: sender.view)
	}

	@objc private func reloadTapped(_ sender: UIButton) {
		cleanup()
		loadAd()
	}

}

// MARK: - MTRGNativeAdDelegate
extension NativeDrawingManualViewController: MTRGNativeAdDelegate {

	func onLoad(with promoBanner: MTRGNativePromoBanner, nativeAd: MTRGNativeAd) {
		render(nativeAd: nativeAd)
		notificationView.showMessage("onLoad() called")
	}

    func onLoadFailed(error: Error, nativeAd: MTRGNativeAd) {
		render(nativeAd: nativeAd)
		notificationView.showMessage("onLoadFailed(\(error)) called")
	}

	func onAdShow(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onAdShow() called")
	}

	func onAdClick(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onAdClick() called")
	}

	func onShowModal(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onShowModal() called")
	}

	func onDismissModal(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onDismissModal() called")
	}

	func onLeaveApplication(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onLeaveApplication() called")
	}

	func onVideoPlay(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onVideoPlay() called")
	}

	func onVideoPause(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onVideoPause() called")
	}

	func onVideoComplete(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onVideoComplete() called")
	}

}

// MARK: - MTRGNativeAdMediaDelegate
extension NativeDrawingManualViewController: MTRGNativeAdMediaDelegate {

	func onIconLoad(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onIconLoad() called")
	}

	func onImageLoad(with nativeAd: MTRGNativeAd) {
		notificationView.showMessage("onImageLoad() called")
	}

	func onAdChoicesIconLoad(with nativeAd: MTRGNativeAd) {
		adChoicesView?.imageView.image = nativeAd.banner?.adChoicesIcon?.image

		notificationView.showMessage("onAdChoicesIconLoad() called")
	}

    func onMediaLoadFailed(with nativeAd: MTRGNativeAd) {
        notificationView.showMessage("onMediaLoadFailed() called")
    }
}
