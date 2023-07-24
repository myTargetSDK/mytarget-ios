//
//  BottomBannerViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 12.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class BottomBannerViewController: UIViewController {

    private let slotId: UInt
    private let query: [String: String]?
    private let adSize: MTRGAdSize?

    private lazy var notificationView: NotificationView = .create(view: view)
    private lazy var refreshControl: UIRefreshControl = .init()
    private lazy var adViewContainer: UIView = {
        let adViewContainer = UIView()
        adViewContainer.backgroundColor = .backgroundColor()
        adViewContainer.isHidden = true
        return adViewContainer
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true

        collectionView.register(GeneralCollectionCell.self, forCellWithReuseIdentifier: GeneralCollectionCell.reuseIdentifier)

        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var adView: MTRGAdView?
    private var isLoading: Bool = false

    init(slotId: UInt, query: [String: String]?, adSize: MTRGAdSize?) {
        self.slotId = slotId
        self.query = query
        self.adSize = adSize
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Banner"

        view.backgroundColor = .backgroundColor()
        view.addSubview(collectionView)
        view.addSubview(adViewContainer)

        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        reloadContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = view.safeAreaInsets

        if !adViewContainer.isHidden, let adView = adView {
            let bottomOffset = safeAreaInsets.bottom

            if adSize?.type == MTRGAdSizeTypeAdaptive {
                // adaptive (manual)
                adView.adSize = MTRGAdSize.forCurrentOrientation()
            }

            let adViewContainerHeight = bottomOffset + adView.adSize.size.height
            adViewContainer.frame = .init(x: 0,
                                          y: view.bounds.height - adViewContainerHeight,
                                          width: view.bounds.width,
                                          height: adViewContainerHeight)

            adView.frame = .init(x: (view.bounds.width - adView.adSize.size.width) / 2,
                                 y: 0,
                                 width: adView.adSize.size.width,
                                 height: adView.adSize.size.height)

            collectionView.frame = view.bounds.inset(by: .init(top: 0, left: 0, bottom: adViewContainerHeight, right: 0))
        } else {
            collectionView.frame = view.bounds
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Banners

    private func loadBanner() {
        adView?.removeFromSuperview()
        adView = nil

        adView = MTRGAdView(slotId: slotId)
        adSize.map { adView?.adSize = $0 }
        adView?.viewController = self
        adView?.delegate = self

        query?.forEach { adView?.customParams.setCustomParam($0.value, forKey: $0.key) }

        adView?.load()
        notificationView.showMessage("Loading...")
    }

    // MARK: - Actions

    @objc private func refreshControlTriggered() {
        reloadContent()
    }

    // MARK: - Private

    private func reloadContent() {
        guard !isLoading else {
            return
        }

        isLoading = true
        loadBanner()
    }

    private func renderContent(withAd isAdExist: Bool) {
        isLoading = false
        refreshControl.endRefreshing()

        if isAdExist, let adView = adView {
            adViewContainer.addSubview(adView)
            adViewContainer.isHidden = false
        } else {
            adViewContainer.isHidden = true
        }

        view.setNeedsLayout()
    }

}

// MARK: - MTRGAdViewDelegate

extension BottomBannerViewController: MTRGAdViewDelegate {

    func onLoad(with adView: MTRGAdView) {
        renderContent(withAd: true)
        notificationView.showMessage("onLoad() called")
    }

    func onLoadFailed(error: Error, adView: MTRGAdView) {
        renderContent(withAd: false)
        notificationView.showMessage("onLoadFailed(\(error)) called")
    }

    func onAdClick(with adView: MTRGAdView) {
        notificationView.showMessage("onAdClick() called")
    }

    func onAdShow(with adView: MTRGAdView) {
        notificationView.showMessage("onAdShow() called")
    }

    func onShowModal(with adView: MTRGAdView) {
        notificationView.showMessage("onShowModal() called")
    }

    func onDismissModal(with adView: MTRGAdView) {
        notificationView.showMessage("onDismissModal() called")
    }

    func onLeaveApplication(with adView: MTRGAdView) {
        notificationView.showMessage("onLeaveApplication() called")
    }

}

// MARK: - UICollectionViewDelegate

extension BottomBannerViewController: UICollectionViewDelegate {}

// MARK: - UICollectionViewDataSource

extension BottomBannerViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: GeneralCollectionCell.reuseIdentifier, for: indexPath)
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension BottomBannerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dummyCell = GeneralCollectionCell()
        return dummyCell.sizeThatFits(collectionView.frame.size)
    }

}
