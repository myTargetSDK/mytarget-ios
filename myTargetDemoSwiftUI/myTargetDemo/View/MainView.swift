//
//  ContentView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 01.09.2022.
//

import SwiftUI
import MyTargetSDK

struct MainView: View {
    let viewModel: MenuViewModel

    var body: some View {
	    NavigationStack {
    	    List {
	    	    ForEach(viewModel.mainAdvertisments) { advertisment in
    	    	    if let items = advertisment.items {
	    	    	    Section(advertisment.title) {
    	    	    	    ForEach(items) { item in
	    	    	    	    NavigationLink(item.title, value: item)
    	    	    	    	    .font(.headline)
    	    	    	    }
	    	    	    }
    	    	    } else {
	    	    	    NavigationLink(value: advertisment) {
    	    	    	    VStack(alignment: .leading) {
	    	    	    	    Text(advertisment.title)
    	    	    	    	    .font(.headline)
	    	    	    	    if let description = advertisment.description {
    	    	    	    	    Text(description)
	    	    	    	    	    .font(.subheadline)
	    	    	    	    }
    	    	    	    }
	    	    	    }
    	    	    }
	    	    }
    	    }
    	    .navigationDestination(for: Advertisment.self) { advertisment in
	    	    switch advertisment.type {
	    	    case .banner(let bannerSize):
    	    	    BannerView(slotId: advertisment.slotId, bannerSize: bannerSize)
	    	    	    .navigationTitle(advertisment.title)
	    	    case .interstitial:
    	    	    InterstitialView(slotId: advertisment.slotId)
	    	    	    .navigationTitle(advertisment.title)
	    	    case .rewarded:
    	    	    RewardedView(slotId: advertisment.slotId)
	    	    	    .navigationTitle(advertisment.title)
	    	    case .native:
    	    	    NativeView(slotId: advertisment.slotId)
	    	    	    .navigationTitle(advertisment.title)
	    	    case .nativeBanner:
    	    	    NativeBannerView(slotId: advertisment.slotId)
	    	    	    .navigationTitle(advertisment.title)
	    	    case .instream:
    	    	    InstreamView(slotId: advertisment.slotId)
	    	    	    .navigationTitle(advertisment.title)
	    	    }
    	    }
    	    .toolbar {
	    	    ToolbarItem(placement: .principal) {
    	    	    VStack {
	    	    	    Text("myTarget Demo")
    	    	    	    .font(.headline)
	    	    	    let version = "SDK version: " + MTRGVersion.currentVersion()
	    	    	    Text(version)
    	    	    	    .font(.subheadline)
    	    	    }
	    	    }
    	    }
	    }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
	    MainView(viewModel: MenuViewModel())
    }
}
