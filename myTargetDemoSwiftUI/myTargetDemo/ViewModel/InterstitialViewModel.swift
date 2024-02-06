//
//  InterstitialViewModel.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 13.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

final class InterstitialViewModel: NSObject, ObservableObject {

    enum InterstitialState {
        case noAd
        case loading
        case loaded(MTRGInterstitialAd)
        case presenting(MTRGInterstitialAd)
    }

    @Published private(set) var state: InterstitialState = .noAd

    private let slotId: UInt
    private var currentAd: MTRGInterstitialAd?

    var isShowButtonEnabled: Bool {
        switch state {
        case .loaded:
            return true
        default:
            return false
        }
    }

    var isLoadButtonEnabled: Bool {
        switch state {
        case .noAd, .loaded:
            return true
        default:
            return false
        }
    }

    var presentingAd: MTRGInterstitialAd? {
        switch state {
        case .presenting(let ad):
            return ad
        default:
            return nil
        }
    }

    init(slotId: UInt) {
        self.slotId = slotId
    }

    func load() {
        let ad = MTRGInterstitialAd(slotId: slotId)
        ad.delegate = self
        ad.load()

        state = .loading
        self.currentAd = ad
    }

    func show() {
	    guard let currentAd = currentAd else {
            state = .noAd
            return
        }

        state = .presenting(currentAd)
    }
}

extension InterstitialViewModel: MTRGInterstitialAdDelegate {
    func onLoad(with interstitialAd: MTRGInterstitialAd) {
        print("InterstitialViewModel: onLoad() called")
        state = .loaded(interstitialAd)
    }

    func onLoadFailed(error: Error, interstitialAd: MTRGInterstitialAd) {
        print("InterstitialViewModel: onLoadFailed() called")
        state = .noAd
        currentAd = nil
    }

    func onNoAd(withReason reason: String, interstitialAd: MTRGInterstitialAd) {
        print("InterstitialViewModel: onNoAd() called")
        state = .noAd
        currentAd = nil
    }

    func onClose(with interstitialAd: MTRGInterstitialAd) {
        print("InterstitialViewModel: onClose() called")
        state = .noAd
        currentAd = nil
    }
}
