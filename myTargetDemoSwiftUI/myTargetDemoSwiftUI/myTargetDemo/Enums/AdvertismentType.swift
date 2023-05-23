//
//  AdvertismentType.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 05.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation

enum AdvertismentType: Codable, Hashable, Equatable {
    case banner(size: BannerSize)
    case interstitial
    case rewarded
    case native
    case nativeBanner
    case instream

    enum BannerSize: Codable, Equatable {
	    case adaptive
	    case fixed320x50
	    case fixed300x250
	    case fixed728x90
    }
}
