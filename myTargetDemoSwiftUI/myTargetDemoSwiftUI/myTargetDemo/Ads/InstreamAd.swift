//
//  InstreamAd.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 06.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI
import MyTargetSDK

struct InstreamAd: UIViewControllerRepresentable {
    typealias UIViewControllerType = InstreamViewController

    private let playerView: UIView
    @Binding var instreamViewController: InstreamViewController?

    init?(playerView: UIView?, instreamViewController: Binding<InstreamViewController?>) {
	    guard let playerView = playerView else {
    	    return nil
	    }
	    self.playerView = playerView
	    self._instreamViewController = instreamViewController
    }

    func makeUIViewController(context: Context) -> InstreamViewController {
	    let instreamViewController = InstreamViewController(playerView: playerView)
	    self.instreamViewController = instreamViewController
	    return instreamViewController
    }

    func updateUIViewController(_ uiViewController: InstreamViewController, context: Context) {
	    //
    }
}
