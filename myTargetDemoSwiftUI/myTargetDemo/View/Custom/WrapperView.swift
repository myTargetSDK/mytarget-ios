//
//  WrapperView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 22.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct WrapperView: UIViewRepresentable {
    typealias UIViewType = UIView
    let view: UIView

    func makeUIView(context: Context) -> UIView {
	    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	    return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
	    //
    }
}
