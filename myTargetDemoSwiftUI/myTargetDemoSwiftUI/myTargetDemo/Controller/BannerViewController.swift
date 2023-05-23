//
//  BannerViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 06.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

final class BannerViewController: UIViewController {
    private let adView: MTRGAdView
    private let bannerSize: AdvertismentType.BannerSize

    init(adView: MTRGAdView, bannerSize: AdvertismentType.BannerSize) {
        MTRGManager.setDebugMode(true)
        self.adView = adView
        self.bannerSize = bannerSize
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(adView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        switch bannerSize {
        case .adaptive:
            adView.adSize = MTRGAdSize.forCurrentOrientation()
            adView.frame = view.bounds
        case .fixed320x50:
            adView.frame = .init(x: 0, y: 0, width: 320, height: 50)
        case .fixed300x250:
            adView.frame = .init(x: 0, y: 0, width: 300, height: 250)
        case .fixed728x90:
            adView.frame = .init(x: 0, y: 0, width: 728, height: 90)
        }
    }
}
