//
//  NativeBannerAd.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 03.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI
import MyTargetSDK

struct NativeBannerAd: UIViewControllerRepresentable {
    typealias UIViewControllerType = NativeBannerViewController
    private let nativeBannerAd: MTRGNativeBannerAd

    init(nativeBannerAd: MTRGNativeBannerAd) {
	    self.nativeBannerAd = nativeBannerAd
    }

    func makeUIViewController(context: Context) -> NativeBannerViewController {
	    return NativeBannerViewController(nativeBannerAd: nativeBannerAd)
    }

    func updateUIViewController(_ uiViewController: NativeBannerViewController, context: Context) {
	    //
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: NativeBannerViewController, context: Context) -> CGSize? {
	    uiViewController.sizeThatFits(CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0))
    }
}

extension NativeBannerAd: Hashable {
    //
}
