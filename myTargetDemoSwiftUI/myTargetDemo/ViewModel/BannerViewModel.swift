//
//  BannerViewModel.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 15.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

final class BannerViewModel: NSObject, ObservableObject {

    private(set) var adView: MTRGAdView
    private(set) var bannerSize: AdvertismentType.BannerSize

    init(slotId: UInt, bannerSize: AdvertismentType.BannerSize) {

        let adView = MTRGAdView(slotId: slotId)
        switch bannerSize {
        case .fixed320x50:
            adView.adSize = MTRGAdSize.adSize320x50()
        case .fixed300x250:
            adView.adSize = MTRGAdSize.adSize300x250()
        case .fixed728x90:
            adView.adSize = MTRGAdSize.adSize728x90()
        default:
            break
        }
	    self.adView = adView
	    self.bannerSize = bannerSize
    }

    func load() {
	    adView.delegate = self
	    adView.load()
    }

}

extension BannerViewModel: MTRGAdViewDelegate {

    func onLoad(with adView: MTRGAdView) {
	    print("BannerViewModel: onLoad() called")
    }

	func onLoadFailed(error: Error, adView: MTRGAdView) {
		print("BannerViewModel: onLoadFailed() called")
	}

    func onNoAd(withReason reason: String, adView: MTRGAdView) {
        print("BannerViewModel: onNoAd() called")
    }
}
