//
//  InstreamView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 06.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct InstreamGrid: View {
    struct Row: Identifiable {
	    var id: String { "\(title) \(value)" }
	    let title: String
	    let value: String
    }
    private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    let header: String
    let rows: [Row]
    init(header: String, rows: [Row]) {
	    self.header = header
	    self.rows = rows
    }
    var body: some View {
	    LazyVGrid(columns: columns, spacing: 8) {
    	    Section {
	    	    ForEach(rows) { row in
    	    	    HStack {
	    	    	    SubheadlineLabelText(row.title)
	    	    	    SubheadlineValueText(row.value)
    	    	    }
	    	    }
    	    } header: {
	    	    HeadlineText(header)
    	    }
	    }
    }
}

struct InstreamView: View {
    @StateObject private var viewModel: InstreamViewModel
    private let duration: TimeInterval = InstreamViewModel.mainVideoDuration

    init(slotId: UInt) {
	    self._viewModel = StateObject(wrappedValue: InstreamViewModel(slotId: slotId))
    }

    var body: some View {
	    ScrollView {
    	    VStack(spacing: 8) {
                let instreamParameters = viewModel.instreamParameters
	    	    InstreamGrid(header: "Instream parameters", rows: [
    	    	    .init(title: "Fullscreen:", value: instreamParameters.fullscreen),
    	    	    .init(title: "Timeout:", value: instreamParameters.timeout),
    	    	    .init(title: "Quality:", value: instreamParameters.quality),
    	    	    .init(title: "Volume:", value: instreamParameters.volume)
	    	    ])

                let currentAdParameters = viewModel.currentAdParameters
	    	    InstreamGrid(header: "Current ad parameters", rows: [
    	    	    .init(title: "Duration:", value: currentAdParameters.duration),
    	    	    .init(title: "Allow pause:", value: currentAdParameters.allowPause),
    	    	    .init(title: "Position:", value: currentAdParameters.position),
    	    	    .init(title: "Allow close:", value: currentAdParameters.allowClose),
    	    	    .init(title: "Dimension:", value: currentAdParameters.dimension),
    	    	    .init(title: "Close delay:", value: currentAdParameters.closeDelay)
	    	    ])

	    	    HeadlineText("Player info")

	    	    HStack {
    	    	    SubheadlineLabelText("Status:")
    	    	    SubheadlineValueText(viewModel.status, maxTextWidth: .infinity)
	    	    }
	    	    // video
	    	    VStack(spacing: 1) {
    	    	    ZStack {
	    	    	    if viewModel.isMainVideoActive {
    	    	    	    WrapperView(view: viewModel.mainVideoView)
	    	    	    } else if viewModel.isAdVideoActive,
                                  let instreamAd = InstreamAd(playerView: viewModel.adPlayerView,
                                                              instreamViewController: $viewModel.currentInstreamViewController) {
                            instreamAd
	    	    	    	    .onDisappear {
    	    	    	    	    viewModel.viewDidDisappear()
	    	    	    	    }
    	    	    	    if !viewModel.isPlayerButtonsHidden {
	    	    	    	    ZStack {
    	    	    	    	    BorderedButton(viewModel.ctaTitle) {
	    	    	    	    	    viewModel.clickButtonTapped()
    	    	    	    	    }
	    	    	    	    }
	    	    	    	    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
	    	    	    	    ZStack {
    	    	    	    	    BorderedButton("Skip") {
	    	    	    	    	    viewModel.skipButtonTapped()
    	    	    	    	    }
    	    	    	    	    .frame(maxWidth: 100)
	    	    	    	    }
	    	    	    	    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
	    	    	    	    ZStack {
    	    	    	    	    BorderedButton("Skip All") {
	    	    	    	    	    viewModel.skipAllButtonTapped()
    	    	    	    	    }
    	    	    	    	    .frame(maxWidth: 100)
	    	    	    	    }
	    	    	    	    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    	    	    	    }
	    	    	    }
    	    	    }
    	    	    .frame(maxWidth: .infinity, minHeight: 200)
    	    	    .border(.black, width: 0.3)
    	    	    ProgressView(duration: duration, position: $viewModel.progressPosition, points: $viewModel.progressPoints)
	    	    	    .frame(height: 6)
	    	    }
	    	    // buttons
	    	    VStack {
    	    	    HStack(spacing: 4) {
	    	    	    BorderedButton("Play") {
    	    	    	    viewModel.playButtonTapped()
	    	    	    }
	    	    	    .disabled(viewModel.isPlayButtonDisabled)
	    	    	    BorderedButton("Pause") {
    	    	    	    viewModel.pauseButtonTapped()
	    	    	    }
	    	    	    .disabled(viewModel.isPauseButtonDisabled)
	    	    	    BorderedButton("Resume") {
    	    	    	    viewModel.resumeButtonTapped()
	    	    	    }
	    	    	    .disabled(viewModel.isResumeButtonDisabled)
	    	    	    BorderedButton("Stop") {
    	    	    	    viewModel.stopButtonTapped()
	    	    	    }
	    	    	    .disabled(viewModel.isStopButtonDisabled)
    	    	    }
    	    	    BorderedButton("Load") {
	    	    	    viewModel.loadButtonTapped()
    	    	    }
    	    	    .disabled(viewModel.isLoadButtonDisabled)
	    	    }
	    	    Spacer()
    	    }
    	    .padding(15)
	    }
    }
}

struct InstreamView_Previews: PreviewProvider {
    static var previews: some View {
	    InstreamView(slotId: Slot.instreamVideo.id)
    }
}
