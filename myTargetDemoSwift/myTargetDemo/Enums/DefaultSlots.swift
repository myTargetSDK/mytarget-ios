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
	enum banner320x50: UInt
	{
		case regular = 30268
		case html = 93229
	}

	enum banner300x250: UInt
	{
		case regular = 64528
		case html = 93231
	}

	enum banner728x90: UInt
	{
		case regular = 81626
		case html = 328709
	}

	case nativePromo = 30294
	case nativeVideo = 30152
	case nativeCards = 54928

	case intertitialPromo = 6899
	case intertitialImage = 6498
	case interstitialHtml = 93233
	case interstitialVast = 101600
	case interstitialCards = 102654

	case intertitialPromoVideo = 22091
	case intertitialPromoVideoStyle = 38838
	case intertitialRewardedVideo = 45102

	case instreamVideo = 9525
}
