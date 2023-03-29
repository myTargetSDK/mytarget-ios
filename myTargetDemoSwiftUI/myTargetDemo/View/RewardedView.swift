//
//  RewardedView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 14.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct RewardedView: View {
	@StateObject private var viewModel: RewardedViewModel

	init(slotId: UInt) {
		self._viewModel = StateObject(wrappedValue: RewardedViewModel(slotId: slotId))
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
				RewardedAd(rewardedAd: ad)
					.ignoresSafeArea()
			}
		}
	}
}

struct RewardedView_Previews: PreviewProvider {
	static var previews: some View {
		RewardedView(slotId: Slot.rewardedVideo.id)
	}
}
