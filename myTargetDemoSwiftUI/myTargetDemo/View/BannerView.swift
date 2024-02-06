//
//  BannerView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 06.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI
import MyTargetSDK

struct BannerView: View {
    @StateObject private var viewModel: BannerViewModel

    init(slotId: UInt, bannerSize: AdvertismentType.BannerSize) {
	    self._viewModel = StateObject(wrappedValue: BannerViewModel(slotId: slotId, bannerSize: bannerSize))
    }

    var body: some View {
	    GeometryReader { geometry in
    	    VStack(spacing: 0) {
	    	    List {
    	    	    ForEach((1...16), id: \.self) { _ in
	    	    	    VStack(alignment: .leading) {
    	    	    	    Text(Constants.Text.loremTitle)
	    	    	    	    .font(.headline)
    	    	    	    Text(Constants.Text.loremDescription)
	    	    	    	    .font(.subheadline)
	    	    	    	    .lineLimit(3)
	    	    	    }
    	    	    }
	    	    }
	    	    makeView(geometry)
    	    }
	    }
	    .onAppear {
    	    viewModel.load()
	    }
    }

    func makeView(_ geometry: GeometryProxy) -> some View {

        let bannerSize = viewModel.bannerSize
        let adSize: MTRGAdSize
        switch bannerSize {
        case .fixed320x50:
            adSize = MTRGAdSize.adSize320x50()
        case .fixed300x250:
            adSize = MTRGAdSize.adSize300x250()
        case .fixed728x90:
            adSize = MTRGAdSize.adSize728x90()
        default:
            adSize = MTRGAdSize(forCurrentOrientationForWidth: geometry.size.width)
        }

	    return BannerAd(adView: viewModel.adView, bannerSize: bannerSize)
    	    .frame(width: adSize.size.width, height: adSize.size.height)
    }
}

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
	    BannerView(slotId: Slot.Standard.bannerAdaptive.id, bannerSize: .adaptive)
    }
}
