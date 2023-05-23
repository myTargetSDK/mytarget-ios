//
//  MainMenu.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 05.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import UIKit

struct MainMenu {
    let mainAdvertisments: [Advertisment]

    init() {
	    let iPad = UIDevice.current.userInterfaceIdiom == .pad
	    let bannersDescription = iPad ? "320x50, 300x250 and 728x90 banners" : "320x50 and 300x250 banners"
	    var bannerItems: [Advertisment] = [
    	    .init(title: "Adaptive", type: .banner(size: .adaptive), slotId: Slot.Standard.bannerAdaptive.id),
    	    .init(title: "320x50", type: .banner(size: .fixed320x50), slotId: Slot.Standard.banner320x50.id),
    	    .init(title: "300x250", type: .banner(size: .fixed300x250), slotId: Slot.Standard.banner300x250.id)
	    ]

	    if iPad {
    	    bannerItems.append(.init(title: "728x90", type: .banner(size: .fixed728x90), slotId: Slot.Standard.banner728x90.id))
	    }

	    let interstitialItems: [Advertisment] = [
    	    .init(title: "Promo", type: .interstitial, slotId: Slot.intertitialPromo.id),
    	    .init(title: "Image", type: .interstitial, slotId: Slot.intertitialImage.id),
    	    .init(title: "Html", type: .interstitial, slotId: Slot.interstitialHtml.id),
    	    .init(title: "Vast", type: .interstitial, slotId: Slot.interstitialVast.id),
    	    .init(title: "Cards", type: .interstitial, slotId: Slot.interstitialCards.id),
    	    .init(title: "Promo Video", type: .interstitial, slotId: Slot.intertitialPromoVideo.id),
    	    .init(title: "Promo Video Style", type: .interstitial, slotId: Slot.intertitialPromoVideoStyle.id),
    	    .init(title: "Rewarded Video", type: .interstitial, slotId: Slot.intertitialRewardedVideo.id)
	    ]
	    let nativeItems: [Advertisment] = [
    	    .init(title: "Promo", type: .native, slotId: Slot.nativePromo.id),
    	    .init(title: "Video", type: .native, slotId: Slot.nativeVideo.id),
    	    .init(title: "Cards", type: .native, slotId: Slot.nativeCards.id)
	    ]

	    mainAdvertisments = [
    	    .init(title: "Banners", description: bannersDescription, type: .banner(size: .adaptive), items: bannerItems),
    	    .init(title: "Interstitial Ads", description: "Fullscreen banners", type: .interstitial, items: interstitialItems),
    	    .init(title: "Rewarded video", description: "Fullscreen rewarded video", type: .rewarded, slotId: Slot.rewardedVideo.id),
    	    .init(title: "Native Ads", description: "Advertisement inside app's content", type: .native, items: nativeItems),
    	    .init(title: "Native Banners", description: "Compact advertisement inside app's content", type: .nativeBanner, slotId: Slot.nativeBanner.id),
    	    .init(title: "In-stream video", description: "Advertisement inside video stream", type: .instream, slotId: Slot.instreamVideo.id)
	    ]

    }
}
