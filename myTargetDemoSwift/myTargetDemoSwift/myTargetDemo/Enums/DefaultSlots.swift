//
//  DefaultSlots.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 23/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import Foundation

enum Slot {

	enum Standard {
		case bannerAdaptive
		case banner320x50
		case banner300x250
		case banner728x90

        var id: UInt {
            switch self {
            case .bannerAdaptive,
                 .banner320x50,
                 .banner728x90:
                return 794557
            case .banner300x250:
                return 93231
            }
		}
	}

	case nativePromo
	case nativeVideo
	case nativeCards
	case nativeBanner

	case intertitialPromo
	case intertitialImage
	case interstitialHtml
	case interstitialVast
	case interstitialCards

	case intertitialPromoVideo
	case intertitialPromoVideoStyle
	case intertitialRewardedVideo

	case rewardedVideo
	case instreamVideo
    case instreamAudio

    var id: UInt {
        switch self {
        case .nativePromo:
            return 30294
        case .nativeVideo:
            return 30152
        case .nativeCards:
            return 54928
        case .nativeBanner:
            return 708246
        case .intertitialPromo:
            return 6899
        case .intertitialImage:
            return 6498
        case .interstitialHtml:
            return 93233
        case .interstitialVast:
            return 101600
        case .interstitialCards:
            return 102654
        case .intertitialPromoVideo:
            return 22091
        case .intertitialPromoVideoStyle:
            return 38838
        case .intertitialRewardedVideo:
            return 45102
        case .rewardedVideo:
            return 577495
        case .instreamVideo:
            return 9525
        case .instreamAudio:
            return 37047
        }
    }
}
