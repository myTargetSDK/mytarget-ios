//
//  RewardedViewModel.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 14.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

final class RewardedViewModel: NSObject, ObservableObject {

    enum RewardedState {
	    case noAd
	    case loading
	    case loaded(MTRGRewardedAd)
	    case presenting(MTRGRewardedAd)
    }

    @Published private(set) var state: RewardedState = .noAd

    private let slotId: UInt
    private var currentAd: MTRGRewardedAd?

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

    var presentingAd: MTRGRewardedAd? {
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
	    let ad = MTRGRewardedAd(slotId: slotId)
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

extension RewardedViewModel: MTRGRewardedAdDelegate {

    func onReward(_ reward: MTRGReward, rewardedAd: MTRGRewardedAd) {
	    print("RewardedViewModel: onReward() called")
    }

    func onLoad(with rewardedAd: MTRGRewardedAd) {
	    print("RewardedViewModel: onLoad() called")
	    state = .loaded(rewardedAd)
    }

    func onLoadFailed(error: Error, rewardedAd: MTRGRewardedAd) {
        print("RewardedViewModel: onLoadFailed() called")
        state = .noAd
        currentAd = nil
    }

    func onNoAd(withReason reason: String, rewardedAd: MTRGRewardedAd) {
        print("RewardedViewModel: onNoAd() called")
        state = .noAd
        currentAd = nil
    }

    func onClose(with rewardedAd: MTRGRewardedAd) {
	    print("RewardedViewModel: onClose() called")
	    state = .noAd
	    currentAd = nil
    }
}
