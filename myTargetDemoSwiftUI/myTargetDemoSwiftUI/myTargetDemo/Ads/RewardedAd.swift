//
//  RewardedAd.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 14.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI
import MyTargetSDK

struct RewardedAd: UIViewControllerRepresentable {
    typealias UIViewControllerType = RewardedViewController
    private let rewardedAd: MTRGRewardedAd

    init(rewardedAd: MTRGRewardedAd) {
	    self.rewardedAd = rewardedAd
    }

    func makeUIViewController(context: Context) -> RewardedViewController {
	    return RewardedViewController(rewardedAd: rewardedAd)
    }

    func updateUIViewController(_ uiViewController: RewardedViewController, context: Context) {
	    //
    }
}
