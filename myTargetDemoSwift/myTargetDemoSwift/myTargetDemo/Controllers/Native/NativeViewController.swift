//
//  NativeViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 12.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class NativeViewController: UIViewController {

    private enum CellType {
        case ad(view: UIView)
        case general
    }

    private let slotId: UInt
    private let query: [String: String]?

    private lazy var notificationView: NotificationView = .create(view: view)
    private lazy var refreshControl: UIRefreshControl = .init()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true

        collectionView.register(GeneralCollectionCell.self, forCellWithReuseIdentifier: GeneralCollectionCell.reuseIdentifier)
        collectionView.register(AdCollectionCell.self, forCellWithReuseIdentifier: AdCollectionCell.reuseIdentifier)
        collectionView.register(LoadingReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: LoadingReusableView.reuseIdentifier)

        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var content: [CellType] = []
    private var nativeAds: [MTRGNativeAd] = []
    private var loadableNativeAd: MTRGNativeAd?
    private var isLoading: Bool = false

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

        view.backgroundColor = .backgroundColor()
        view.addSubview(collectionView)

        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        reloadContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Native Ad

    private func loadNativeAd() {
        loadableNativeAd = MTRGNativeAd(slotId: slotId)
        query?.forEach { loadableNativeAd?.customParams.setCustomParam($0.value, forKey: $0.key) }
        loadableNativeAd?.delegate = self

        loadableNativeAd?.load()
        notificationView.showMessage("Loading...")
    }

    private func loadMultipleNativeAds() {
        let nativeAdLoader = MTRGNativeAdLoader(forCount: 3, slotId: slotId)
        query?.forEach { nativeAdLoader.customParams.setCustomParam($0.value, forKey: $0.key) }

        nativeAdLoader.load { [weak self] nativeAds, error in
            guard let self = self else {
                return
            }
            if let error = error {
                self.notificationView.showMessage("Loading error: \(error.localizedDescription)")
            } else {
                self.renderContent(with: nativeAds, shouldPreClean: true)
                self.notificationView.showMessage("Loaded \(nativeAds.count) ads")
            }
        }
        notificationView.showMessage("Loading...")
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
        loadMultipleNativeAds()
    }

    private func loadMoreContent() {
        guard !isLoading else {
            return
        }

        isLoading = true
        loadNativeAd()
    }

    private func renderContent(with nativeAds: [MTRGNativeAd], shouldPreClean: Bool = false) {
        isLoading = false
        refreshControl.endRefreshing()

        let nativeViews = nativeAds.compactMap { nativeAd -> UIView? in
            guard let banner = nativeAd.banner else {
                return nil
            }

            let adView = createNativeView(from: banner)
            nativeAd.register(adView, with: self)
            return adView
        }

        if shouldPreClean {
            self.nativeAds = nativeAds
            content.removeAll()
        } else {
            self.nativeAds.append(contentsOf: nativeAds)
        }

        let batchCount = 16
        for index in 0..<nativeViews.count * batchCount {
            // every third cell in a batch will be an ad
            let cellType: CellType = index % batchCount - 2 == 0 ? .ad(view: nativeViews[index / batchCount]) : .general
            content.append(cellType)
        }

        collectionView.reloadData()
    }

}

// MARK: - MTRGNativeAdDelegate

extension NativeViewController: MTRGNativeAdDelegate {

    func onLoad(with promoBanner: MTRGNativePromoBanner, nativeAd: MTRGNativeAd) {
        loadableNativeAd.map { renderContent(with: [$0]) }
        loadableNativeAd = nil
        notificationView.showMessage("onLoad() called")
    }

    func onLoadFailed(error: Error, nativeAd: MTRGNativeAd) {
        loadableNativeAd.map { renderContent(with: [$0]) }
        loadableNativeAd = nil
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

// MARK: - MTRGMediaAdViewDelegate

extension NativeViewController: MTRGMediaAdViewDelegate {

    func onImageSizeChanged(_ mediaAdView: MTRGMediaAdView) {
        collectionView.reloadData()
    }

}

// MARK: - UICollectionViewDelegate

extension NativeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == UICollectionView.elementKindSectionFooter else {
            return
        }

        loadMoreContent()
    }

}

// MARK: - UICollectionViewDataSource

extension NativeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch content[indexPath.row] {
        case .ad(let view):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCollectionCell.reuseIdentifier, for: indexPath)
            (cell as? AdCollectionCell)?.adView = view
            return cell
        case .general:
            return collectionView.dequeueReusableCell(withReuseIdentifier: GeneralCollectionCell.reuseIdentifier, for: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else {
            return UICollectionReusableView()
        }

        let loadingView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                          withReuseIdentifier: LoadingReusableView.reuseIdentifier,
                                                                          for: indexPath)
        return loadingView
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension NativeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch content[indexPath.row] {
        case .ad(let view):
            return view.sizeThatFits(collectionView.frame.size)
        case .general:
            let dummyCell = GeneralCollectionCell()
            return dummyCell.sizeThatFits(collectionView.frame.size)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return content.isEmpty ? .zero : CGSize(width: collectionView.bounds.size.width, height: 32)
    }

}
