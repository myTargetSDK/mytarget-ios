//
//  NativeView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 17.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI
import MyTargetSDK

struct NativeView: View {
    @StateObject private var viewModel: NativeViewModel

    init(slotId: UInt) {
	    self._viewModel = StateObject(wrappedValue: NativeViewModel(slotId: slotId))
    }

    var body: some View {
	    List {
    	    ForEach(viewModel.cells) { cell in
                switch cell {
                case .ad(let nativeAd):
                    nativeAd
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

struct NativeView_Previews: PreviewProvider {
    static var previews: some View {
	    NativeView(slotId: Slot.nativePromo.id)
    }
}
