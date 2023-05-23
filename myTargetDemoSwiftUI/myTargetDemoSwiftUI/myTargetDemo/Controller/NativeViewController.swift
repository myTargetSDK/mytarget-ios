//
//  NativeViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 17.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

final class NativeViewController: UIViewController {
    private let nativeAd: MTRGNativeAd
    private var nativeView: UIView?

    init(nativeAd: MTRGNativeAd) {
	    MTRGManager.setDebugMode(true)
	    self.nativeAd = nativeAd

	    super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
	    super.viewDidLoad()
	    handleNativeAd(nativeAd)
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

    private func handleNativeAd(_ nativeAd: MTRGNativeAd) {
	    guard let promoBanner = nativeAd.banner else {
    	    return
	    }
	    let nativeView = createNativeView(from: promoBanner)
	    nativeAd.register(nativeView, with: UIApplication.rootViewController() ?? self)
	    view.addSubview(nativeView)
	    self.nativeView = nativeView
    }

    private func createNativeView(from promoBanner: MTRGNativePromoBanner) -> UIView {
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
}

// MARK: - MTRGMediaAdViewDelegate

extension NativeViewController: MTRGMediaAdViewDelegate {
    func onImageSizeChanged(_ mediaAdView: MTRGMediaAdView) {
	    //
    }
}
