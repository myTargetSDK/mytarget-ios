//
//  DefaultSlots.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 23/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import Foundation

enum Slot: UInt
{
	enum standard: UInt
	{
		case bannerAdaptive
		case banner320x50
		case banner300x250
		case banner728x90

		var rawValue: UInt
		{
			switch self
			{
			case .bannerAdaptive:
				return 794557
			case .banner320x50:
				return 794557
			case .banner300x250:
				return 93231
			case .banner728x90:
				return 794557
			}
		}

	}

	case nativePromo = 30294
	case nativeVideo = 30152
	case nativeCards = 54928

	case nativeBanner = 708246

	case intertitialPromo = 6899
	case intertitialImage = 6498
	case interstitialHtml = 93233
	case interstitialVast = 101600
	case interstitialCards = 102654

	case intertitialPromoVideo = 22091
	case intertitialPromoVideoStyle = 38838
	case intertitialRewardedVideo = 45102

	case rewardedVideo = 577495

	case instreamVideo = 9525
}
