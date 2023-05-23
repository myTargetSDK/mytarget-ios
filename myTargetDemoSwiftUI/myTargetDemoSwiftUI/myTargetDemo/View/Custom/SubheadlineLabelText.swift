//
//  SubheadlineLabelText.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 16.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct SubheadlineLabelText: View {
    private let text: String

    init(_ text: String) {
	    self.text = text
    }

    var body: some View {
	    Text(text)
    	    .lineLimit(1)
    	    .frame(maxWidth: .infinity, alignment: .leading)
    	    .font(.subheadline)
    }
}

struct SubheadlineLabelText_Previews: PreviewProvider {
    static var previews: some View {
	    SubheadlineLabelText("Text")
    }
}
