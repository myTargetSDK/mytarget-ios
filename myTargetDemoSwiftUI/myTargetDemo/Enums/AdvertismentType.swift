//
//  AdvertismentType.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 05.09.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation

enum AdvertismentType: Codable, Hashable {
	case banner(size: BannerSize)
	case interstitial
	case rewarded
	case native
	case nativeBanner
	case instream

	enum BannerSize: Codable {
		case adaptive
		case fixed320x50
		case fixed300x250
		case fixed728x90
	}

}

extension AdvertismentType: Equatable {
	static func == (lhs: AdvertismentType, rhs: AdvertismentType) -> Bool {
		switch(lhs, rhs) {
			case(let .banner(size1), let .banner(size2)):
			   return size1 == size2
			case(.interstitial, .interstitial):
				return true
			case(.rewarded, .rewarded):
				return true
			case(.native, .native):
				return true
			case(.nativeBanner, .nativeBanner):
				return true
			case(.instream, .instream):
				return true
			default:
			   return false
		}
	}
}
