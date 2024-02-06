//
//  ProgressView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 22.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct ProgressView: UIViewRepresentable {
    typealias UIViewType = VideoProgressView

    let duration: TimeInterval

    @Binding var position: TimeInterval
    @Binding var points: [Double]

    func makeUIView(context: Context) -> VideoProgressView {
	    VideoProgressView(duration: duration)
    }

    func updateUIView(_ uiView: VideoProgressView, context: Context) {
	    uiView.position = position
	    uiView.points = points
    }
}
