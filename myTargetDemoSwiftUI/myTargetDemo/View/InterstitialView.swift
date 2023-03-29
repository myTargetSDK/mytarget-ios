//
//  InterstitialView.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 13.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct InterstitialView: View {
    @StateObject private var viewModel: InterstitialViewModel

    init(slotId: UInt) {
        self._viewModel = StateObject(wrappedValue: InterstitialViewModel(slotId: slotId))
    }

    var body: some View {
        ZStack {
			VStack {
				HStack {
					BorderedButton("Load") {
						viewModel.load()
					}
					.buttonStyle(.bordered)
					.disabled(!viewModel.isLoadButtonEnabled)

					BorderedButton("Show") {
						viewModel.show()
					}
					.buttonStyle(.borderedProminent)
					.disabled(!viewModel.isShowButtonEnabled)
				}
				.padding(15)
				if let state = viewModel.state {
					switch state {
						case .noAd:
							Text("Ad isn't loaded")
						case .loading:
							Text("Loading...")
						case .loaded(_):
							Text("Loaded")
						case .presenting(_):
							Text("Presenting...")
					}
				}
			}

            if let ad = viewModel.presentingAd {
                InterstitialAd(interstitialAd: ad)
                    .ignoresSafeArea()
            }
        }
    }
}

struct InterstitialView_Previews: PreviewProvider {
    static var previews: some View {
        InterstitialView(slotId: Slot.intertitialImage.id)
    }
}
