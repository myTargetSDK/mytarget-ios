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
                stateText()
    	    }

            if let ad = viewModel.presentingAd {
                InterstitialAd(interstitialAd: ad)
                    .ignoresSafeArea()
            }
        }
    }

    private func stateText() -> some View {
        switch viewModel.state {
        case .noAd:
            return Text("Ad isn't loaded")
        case .loading:
            return Text("Loading...")
        case .loaded:
            return Text("Loaded")
        case .presenting:
            return Text("Presenting...")
        }
    }
}

struct InterstitialView_Previews: PreviewProvider {
    static var previews: some View {
        InterstitialView(slotId: Slot.intertitialImage.id)
    }
}
