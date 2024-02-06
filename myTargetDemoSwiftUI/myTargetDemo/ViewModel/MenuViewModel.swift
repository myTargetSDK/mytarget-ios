//
//  MenuViewModel.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 05.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import SwiftUI

final class MenuViewModel {
    private let menu = MainMenu()

    var mainAdvertisments: [Advertisment] {
	    menu.mainAdvertisments
    }
}
