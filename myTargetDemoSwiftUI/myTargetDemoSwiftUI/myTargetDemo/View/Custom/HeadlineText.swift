//
//  HeadlineText.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 16.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct HeadlineText: View {
    private let text: String

    init(_ text: String) {
	    self.text = text
    }

    var body: some View {
	    Text(text)
    	    .lineLimit(1)
    	    .font(.headline)
    	    .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HeadlineText_Previews: PreviewProvider {
    static var previews: some View {
	    HeadlineText("Text")
    }
}
