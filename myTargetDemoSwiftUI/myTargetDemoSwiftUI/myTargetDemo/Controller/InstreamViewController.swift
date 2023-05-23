//
//  InstreamViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 06.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

final class InstreamViewController: UIViewController {
    private let playerView: UIView

    init(playerView: UIView) {
	    MTRGManager.setDebugMode(true)
	    self.playerView = playerView
	    super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
	    super.viewDidLoad()
	    playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	    view.addSubview(playerView)
    }

    override func viewDidLayoutSubviews() {
	    super.viewDidLayoutSubviews()
	    playerView.frame = view.bounds
    }
}
