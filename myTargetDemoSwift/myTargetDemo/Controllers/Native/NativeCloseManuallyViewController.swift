//
//  NativeCloseManuallyViewController.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 11.10.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class NativeCloseManuallyViewController: UIViewController {

	private let slotId: UInt
	private let query: [String: String]?

	private lazy var notificationView: NotificationView = .create(view: view)
	private lazy var reloadButton: CustomButton = .init(title: "Reload")

	private let adViewMaxSize: CGSize = .init(width: 300, height: 250)
	private let reloadButtonInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 16, right: 16)
	private let buttonHeight: CGFloat = 40

	// Use this flag for customize hide behavoir
	// See MTRGNativeAd's adChoicesOptionDelegate property and MTRGNativeAdChoicesOptionDelegate protocol for more details
	private var shouldHideAdManually = true

	private var isLoading: Bool = false {
		didSet {
			reloadButton.isEnabled = !isLoading
		}
	}

	// Current ad
	private var adContainerView: UIView?
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
		nativeAd.adChoicesOptionDelegate = self
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
	}

	func render(nativeAd: MTRGNativeAd) {
		isLoading = false

		guard let promoBanner = nativeAd.banner else {
			notificationView.showMessage("No banner info")
			return
		}

		let nativeAdContainer = createNativeView(from: promoBanner)
		nativeAd.register(nativeAdContainer, with: self)
		view.addSubview(nativeAdContainer)

		self.adContainerView = nativeAdContainer
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

	@objc private func reloadTapped(_ sender: UIButton) {
		cleanup()
		loadAd()
	}

}

// MARK: - MTRGNativeAdChoicesOptionDelegate
extension NativeCloseManuallyViewController: MTRGNativeAdChoicesOptionDelegate {

	// SDK use this method to decide, should it close ad or not
	// Return true for closing by SDK or false for manually
	// Method is optional and returns true by default
	func shouldCloseAutomatically() -> Bool {
		return !shouldHideAdManually
	}

	// Calls when SDK hides ad (when `shouldCloseAutomatically` returns true)
	func onCloseAutomatically(_ nativeAd: MTRGNativeAd!) {
		notificationView.showMessage("onCloseAutomatically() called")
	}

	// This method calls when you should hide ad manually (when `shouldCloseAutomatically` returns false)
	func closeIfAutomaticallyDisabled(_ nativeAd: MTRGNativeAd!) {
		adContainerView?.isHidden = true
		notificationView.showMessage("closeIfAutomaticallyDisabled() called")
	}

}

// MARK: - MTRGNativeAdDelegate
extension NativeCloseManuallyViewController: MTRGNativeAdDelegate {

	func onLoad(with promoBanner: MTRGNativePromoBanner, nativeAd: MTRGNativeAd) {
		render(nativeAd: nativeAd)
		notificationView.showMessage("onLoad() called")
	}

    func onLoadFailed(error: Error, nativeAd: MTRGNativeAd) {
		render(nativeAd: nativeAd)
		notificationView.showMessage("onLoadFailed(\(error)) called")
	}

}
