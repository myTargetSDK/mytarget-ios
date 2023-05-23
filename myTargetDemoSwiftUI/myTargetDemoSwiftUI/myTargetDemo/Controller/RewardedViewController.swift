//
//  RewardedViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 14.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import UIKit
import MyTargetSDK

final class RewardedViewController: UIViewController {

    private let rewardedAd: MTRGRewardedAd
    private var didShowAd = false

    init(rewardedAd: MTRGRewardedAd) {
	    self.rewardedAd = rewardedAd
	    super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
	    super.viewDidAppear(animated)

	    guard !didShowAd else {
    	    return
	    }

	    rewardedAd.show(with: self)
	    didShowAd = true
    }

}
