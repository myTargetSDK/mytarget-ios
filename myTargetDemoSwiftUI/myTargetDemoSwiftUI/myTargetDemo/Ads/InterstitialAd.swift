//
//  InterstitialAd.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 13.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI
import MyTargetSDK

struct InterstitialAd: UIViewControllerRepresentable {
    typealias UIViewControllerType = InterstitialViewController
    private let interstitialAd: MTRGInterstitialAd

    init(interstitialAd: MTRGInterstitialAd) {
        self.interstitialAd = interstitialAd
    }

    func makeUIViewController(context: Context) -> InterstitialViewController {
        return InterstitialViewController(interstitialAd: interstitialAd)
    }

    func updateUIViewController(_ uiViewController: InterstitialViewController, context: Context) {
	    //
    }
}
