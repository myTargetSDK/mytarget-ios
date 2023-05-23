//
//  BannerAd.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 06.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI
import MyTargetSDK

struct BannerAd: UIViewControllerRepresentable {
    typealias UIViewControllerType = BannerViewController
    private let adView: MTRGAdView
    private let bannerSize: AdvertismentType.BannerSize

    init(adView: MTRGAdView, bannerSize: AdvertismentType.BannerSize) {
    	self.adView = adView
    	self.bannerSize = bannerSize
    }

    func makeUIViewController(context: Context) -> BannerViewController {
	    return BannerViewController(adView: adView, bannerSize: bannerSize)
    }

    func updateUIViewController(_ uiViewController: BannerViewController, context: Context) {
	    //
    }
}
