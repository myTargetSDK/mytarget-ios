//
//  InterstitialViewController.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 13.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import UIKit
import MyTargetSDK

final class InterstitialViewController: UIViewController {

    private let interstitialAd: MTRGInterstitialAd
    private var didShowAd = false

    init(interstitialAd: MTRGInterstitialAd) {
        self.interstitialAd = interstitialAd
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

        interstitialAd.show(with: self)
        didShowAd = true
    }

}
