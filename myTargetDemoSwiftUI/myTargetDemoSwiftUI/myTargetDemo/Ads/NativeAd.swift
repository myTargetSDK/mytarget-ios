//
//  NativeAd.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 03.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI
import MyTargetSDK

struct NativeAd: UIViewControllerRepresentable {
    typealias UIViewControllerType = NativeViewController
    private let nativeAd: MTRGNativeAd

    init(nativeAd: MTRGNativeAd) {
	    self.nativeAd = nativeAd
    }

    func makeUIViewController(context: Context) -> NativeViewController {
	    return NativeViewController(nativeAd: nativeAd)
    }

    func updateUIViewController(_ uiViewController: NativeViewController, context: Context) {
	    //
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiViewController: NativeViewController, context: Context) -> CGSize? {
	    uiViewController.sizeThatFits(CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0))
    }
}

extension NativeAd: Hashable {
    //
}
