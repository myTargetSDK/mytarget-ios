//
//  AdvertismentType.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19/06/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import Foundation

enum AdvertismentType: Codable {
    case banner
    case interstitial
    case rewarded
    case native
    case nativeBanner
    case instream
    case instreamAudio
}
