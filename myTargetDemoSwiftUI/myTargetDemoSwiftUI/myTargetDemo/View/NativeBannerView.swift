//
//  NativeBannerView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 03.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI
import MyTargetSDK

struct NativeBannerView: View {
    @StateObject private var viewModel: NativeBannerViewModel

    init(slotId: UInt) {
	    self._viewModel = StateObject(wrappedValue: NativeBannerViewModel(slotId: slotId))
    }

    var body: some View {
	    List {
            ForEach(viewModel.cells) { cell in
                switch cell {
                case .ad(let nativeBannerAd):
                    nativeBannerAd
                case .general:
                    VStack(alignment: .leading) {
                        Text(Constants.Text.loremTitle)
                            .font(.headline)
                        Text(Constants.Text.loremDescription)
                            .font(.subheadline)
                            .lineLimit(3)
                    }
	    	    }
            }
	    }
	    .onAppear {
    	    viewModel.loadAdvertisements()
	    }
    }
}

struct NativeBannerView_Previews: PreviewProvider {
    static var previews: some View {
	    NativeBannerView(slotId: Slot.nativeBanner.id)
    }
}
