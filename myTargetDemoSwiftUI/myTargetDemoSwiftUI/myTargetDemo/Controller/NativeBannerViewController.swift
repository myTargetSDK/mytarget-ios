//
//  NativeBannerViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 03.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

final class NativeBannerViewController: UIViewController {
    private let nativeBannerAd: MTRGNativeBannerAd
    private var nativeView: UIView?

    init(nativeBannerAd: MTRGNativeBannerAd) {
	    MTRGManager.setDebugMode(true)
	    self.nativeBannerAd = nativeBannerAd

	    super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
	    super.viewDidLoad()
	    handleNativeBannerAd(nativeBannerAd)
    }

    override func viewDidLayoutSubviews() {
	    super.viewDidLayoutSubviews()
	    nativeView?.frame = view.bounds
    }

    func sizeThatFits(_ size: CGSize) -> CGSize? {
	    guard let nativeView = nativeView else {
    	    return nil
	    }
	    return nativeView.sizeThatFits(size)
    }

    // MARK: - private

    private func handleNativeBannerAd(_ nativeBannerAd: MTRGNativeBannerAd) {
	    guard let banner = nativeBannerAd.banner else {
    	    return
	    }
	    let nativeView = createNativeBannerView(from: banner)
	    nativeBannerAd.register(nativeView, with: UIApplication.rootViewController() ?? self)
	    view.addSubview(nativeView)
	    self.nativeView = nativeView
    }

    private func createNativeBannerView(from banner: MTRGNativeBanner) -> UIView {
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
}
