//
//  BannerViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 15.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class BannerViewController: UIViewController {

    private enum CellType {
        case ad(view: MTRGAdView)
        case general
    }

    private let slotId: UInt
    private let query: [String: String]?
    private var adView: MTRGAdView?
    private let adSize: MTRGAdSize?
    private let adContentIndex: Int = 2

    private lazy var notificationView: NotificationView = .create(view: view)
    private lazy var refreshControl: UIRefreshControl = .init()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true

        collectionView.register(GeneralCollectionCell.self, forCellWithReuseIdentifier: GeneralCollectionCell.reuseIdentifier)
        collectionView.register(AdCollectionCell.self, forCellWithReuseIdentifier: AdCollectionCell.reuseIdentifier)

        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()

    private var content: [CellType] = []
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

        refreshControl.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        reloadContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds

        if adSize?.type == MTRGAdSizeTypeAdaptive, content.count > adContentIndex, case .ad(let adView) = content[adContentIndex] {
            adView.adSize = MTRGAdSize(forCurrentOrientationForWidth: collectionView.frame.width)
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
        let adView = MTRGAdView(slotId: slotId)
        adSize.map { adView.adSize = $0 }
        adView.viewController = self
        adView.delegate = self

        query?.forEach { adView.customParams.setCustomParam($0.value, forKey: $0.key) }

        self.adView = adView
        isLoading = true

        adView.load()
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

        loadBanner()
    }

    private func renderContent(for adView: MTRGAdView?) {
        isLoading = false
        refreshControl.endRefreshing()

        content = Array(repeating: .general, count: 16)
        adView.map { content[adContentIndex] = .ad(view: $0) }

        collectionView.reloadData()
    }

}

// MARK: - MTRGAdViewDelegate

extension BannerViewController: MTRGAdViewDelegate {

    func onLoad(with adView: MTRGAdView) {
        renderContent(for: adView)
        notificationView.showMessage("onLoad() called")
    }

    func onLoadFailed(error: Error, adView: MTRGAdView) {
        self.adView = nil
        renderContent(for: nil)
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

extension BannerViewController: UICollectionViewDelegate {}

// MARK: - UICollectionViewDataSource

extension BannerViewController: UICollectionViewDataSource {

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

}

// MARK: - UICollectionViewDelegateFlowLayout

extension BannerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch content[indexPath.row] {
        case .ad(let view):
            return .init(width: collectionView.frame.width, height: view.adSize.size.height)
        case .general:
            let dummyCell = GeneralCollectionCell()
            return dummyCell.sizeThatFits(collectionView.frame.size)
        }
    }

}
