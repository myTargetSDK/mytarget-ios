//
//  BorderedButton.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 16.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct BorderedButton: View {
    private let text: String
    private let action: () -> Void

    init(_ text: String, action: @escaping () -> Void) {
	    self.text = text
	    self.action = action
    }

    var body: some View {
	    Button {
    	    action()
	    } label: {
    	    Text(text)
	    	    .lineLimit(1)
	    	    .frame(maxWidth: .infinity)
	    }
	    .buttonStyle(.bordered)
    }
}

struct BorderedButton_Previews: PreviewProvider {
    static var previews: some View {
	    BorderedButton("Text") {
    	    //
	    }
    }
}
