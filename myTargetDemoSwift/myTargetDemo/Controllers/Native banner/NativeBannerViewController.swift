//
//  NativeBannerViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 10.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class NativeBannerViewController: UIViewController {

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
    private var nativeBannerAds: [MTRGNativeBannerAd] = []
    private var loadableNativeBannerAd: MTRGNativeBannerAd?
    private var isLoading: Bool = false

    init(slotId: UInt? = nil, query: [String: String]? = nil) {
        self.slotId = slotId ?? Slot.nativeBanner.id
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Native Banners"

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

    // MARK: - Native Banner Ad

    private func loadNativeBannerAd() {
        loadableNativeBannerAd = MTRGNativeBannerAd(slotId: slotId)
        query?.forEach { loadableNativeBannerAd?.customParams.setCustomParam($0.value, forKey: $0.key) }
        loadableNativeBannerAd?.delegate = self

        loadableNativeBannerAd?.load()
        notificationView.showMessage("Loading...")
    }

    private func loadMultipleNativeBannerAds() {
        let nativeBannerAdLoader = MTRGNativeBannerAdLoader(forCount: 3, slotId: slotId)
        query?.forEach { nativeBannerAdLoader.customParams.setCustomParam($0.value, forKey: $0.key) }

        nativeBannerAdLoader.load { [weak self] nativeBannerAds, error in
            guard let self = self else {
                return
            }
            if let error = error {
                self.notificationView.showMessage("Loading error: \(error.localizedDescription)")
            } else {
                self.renderContent(with: nativeBannerAds, shouldPreClean: true)
                self.notificationView.showMessage("Loaded \(nativeBannerAds.count) ads")
            }
        }
        notificationView.showMessage("Loading...")
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
        loadMultipleNativeBannerAds()
    }

    private func loadMoreContent() {
        guard !isLoading else {
            return
        }

        isLoading = true
        loadNativeBannerAd()
    }

    private func renderContent(with nativeBannerAds: [MTRGNativeBannerAd], shouldPreClean: Bool = false) {
        isLoading = false
        refreshControl.endRefreshing()

        let nativeBannerViews = nativeBannerAds.compactMap { nativeBannerAd -> UIView? in
            guard let banner = nativeBannerAd.banner else {
                return nil
            }

            let adView = createNativeBannerView(from: banner)
            nativeBannerAd.register(adView, with: self)
            return adView
        }

        if shouldPreClean {
            self.nativeBannerAds = nativeBannerAds
            content.removeAll()
        } else {
            self.nativeBannerAds.append(contentsOf: nativeBannerAds)
        }

        let batchCount = 16
        for index in 0..<nativeBannerViews.count * batchCount {
            // every third cell in a batch will be an ad
            let cellType: CellType = index % batchCount - 2 == 0 ? .ad(view: nativeBannerViews[index / batchCount]) : .general
            content.append(cellType)
        }

        collectionView.reloadData()
    }

}

// MARK: - MTRGNativeBannerAdDelegate

extension NativeBannerViewController: MTRGNativeBannerAdDelegate {

    func onLoad(with banner: MTRGNativeBanner, nativeBannerAd: MTRGNativeBannerAd) {
        loadableNativeBannerAd.map { renderContent(with: [$0]) }
        loadableNativeBannerAd = nil
        notificationView.showMessage("onLoad() called")
    }

    func onLoadFailed(error: Error, nativeBannerAd: MTRGNativeBannerAd) {
        loadableNativeBannerAd.map { renderContent(with: [$0]) }
        loadableNativeBannerAd = nil
        notificationView.showMessage("onLoadFailed(\(error)) called")
    }

    func onAdShow(with nativeBannerAd: MTRGNativeBannerAd) {
        notificationView.showMessage("onAdShow() called")
    }

    func onAdClick(with nativeBannerAd: MTRGNativeBannerAd) {
        notificationView.showMessage("onAdClick() called")
    }

    func onShowModal(with nativeBannerAd: MTRGNativeBannerAd) {
        notificationView.showMessage("onShowModal() called")
    }

    func onDismissModal(with nativeBannerAd: MTRGNativeBannerAd) {
        notificationView.showMessage("onDismissModal() called")
    }

    func onLeaveApplication(with nativeBannerAd: MTRGNativeBannerAd) {
        notificationView.showMessage("onLeaveApplication() called")
    }

}

// MARK: - UICollectionViewDelegate

extension NativeBannerViewController: UICollectionViewDelegate {

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

extension NativeBannerViewController: UICollectionViewDataSource {

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

extension NativeBannerViewController: UICollectionViewDelegateFlowLayout {

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
