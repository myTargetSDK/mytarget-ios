//
//  SubheadlineValueText.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 16.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct SubheadlineValueText: View {
    private let text: String
    private let maxTextWidth: CGFloat

    init(_ text: String, maxTextWidth: CGFloat = 75) {
	    self.text = text
	    self.maxTextWidth = maxTextWidth
    }

    var body: some View {
	    Text(text)
    	    .bold()
    	    .lineLimit(1)
    	    .frame(maxWidth: maxTextWidth, alignment: .trailing)
    	    .font(.subheadline)
    }
}

struct SubheadlineValueText_Previews: PreviewProvider {
    static var previews: some View {
	    SubheadlineValueText("Text")
    }
}
