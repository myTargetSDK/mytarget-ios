//
//  SplashScreen.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 03.10.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

struct SplashView: View {

    @State var isActive: Bool = false

    var body: some View {
	    VStack {
    	    if self.isActive {
	    	    MainView(viewModel: MenuViewModel())
    	    } else {
	    	    Spacer()
	    	    Text("myTarget Demo")
    	    	    .font(Font.largeTitle)
	    	    Spacer()
	    	    Text("© VK")
    	    }
	    }
	    .onAppear {
    	    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
	    	    withAnimation {
    	    	    self.isActive = true
	    	    }
    	    }
	    }
    }
}
