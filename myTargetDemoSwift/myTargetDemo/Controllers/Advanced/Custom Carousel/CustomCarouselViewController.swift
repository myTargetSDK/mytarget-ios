//
//  CustomCarouselViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 14.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class CustomCarouselViewController: UIViewController {
    private let slotId: UInt = Slot.nativeCards.id

    private lazy var notificationView: NotificationView = .create(view: view)

    private lazy var nativeAd: MTRGNativeAd = {
        let nativeAd = MTRGNativeAd(slotId: slotId)
        nativeAd.delegate = self
        return nativeAd
    }()

    private var adContainerView: UIView?

    private let defaultMargin: CGFloat = 16

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Custom Carousel"
        view.backgroundColor = .secondaryBackgroundColor()

        loadNativeAd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let adContainerView = adContainerView else {
            return
        }

        let safeAreaInsets = view.safeAreaInsets
        let horizontalInsets = safeAreaInsets.left + safeAreaInsets.right + defaultMargin * 2
        let verticalInsets = safeAreaInsets.top + safeAreaInsets.bottom + defaultMargin * 2

        let contentSize = CGSize(width: view.bounds.size.width - horizontalInsets,
                                 height: view.bounds.size.height - verticalInsets)
        let size = adContainerView.sizeThatFits(contentSize)
        adContainerView.frame = .init(x: (view.bounds.width - size.width) / 2,
                                      y: (view.bounds.height - size.height) / 2,
                                      width: size.width,
                                      height: size.height)
    }

    private func loadNativeAd() {
        nativeAd.load()
        notificationView.showMessage("Loading...")
    }

    private func createNativeView(from promoBanner: MTRGNativePromoBanner) -> UIView {
        let nativeAdView = CustomNativeAdView(banner: promoBanner)

        let nativeAdContainer = MTRGNativeAdContainer.create(withAdView: nativeAdView)
        nativeAdContainer.advertisingView = nativeAdView.adLabel
        nativeAdContainer.titleView = nativeAdView.titleLabel
        nativeAdContainer.descriptionView = nativeAdView.descriptionLabel
        nativeAdContainer.iconView = nativeAdView.iconAdView
        nativeAdContainer.mediaView = nativeAdView.mediaAdView
        nativeAdContainer.categoryView = nativeAdView.categoryLabel
        nativeAdContainer.ratingView = nativeAdView.ratingStarsLabel
        nativeAdContainer.votesView = nativeAdView.votesLabel
        nativeAdContainer.ctaView = nativeAdView.buttonView

        return nativeAdContainer
    }

    private func renderContent(of promoBanner: MTRGNativePromoBanner) {
        let adView = createNativeView(from: promoBanner)
        nativeAd.register(adView, with: self)
        view.addSubview(adView)
        adContainerView = adView
    }

    private func cleanup() {
        nativeAd.unregisterView()
        adContainerView?.removeFromSuperview()
    }

}

// MARK: - MTRGNativeAdDelegate

extension CustomCarouselViewController: MTRGNativeAdDelegate {

    func onLoad(with promoBanner: MTRGNativePromoBanner, nativeAd: MTRGNativeAd) {
        renderContent(of: promoBanner)
        notificationView.showMessage("onLoad() called")
    }

    func onLoadFailed(error: Error, nativeAd: MTRGNativeAd) {
        cleanup()
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

}
