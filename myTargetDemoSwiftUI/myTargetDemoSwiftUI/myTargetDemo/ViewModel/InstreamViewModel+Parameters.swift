//
//  InstreamViewModel+Parameters.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 15.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation

extension InstreamViewModel {
    private static let valueNotAvailable = "n/a"

    struct InstreamParameters {
        var fullscreen: String
        var quality: String
        var timeout: String
        var volume: String

        static let initial = Self(fullscreen: valueNotAvailable,
                                  quality: valueNotAvailable,
                                  timeout: valueNotAvailable,
                                  volume: valueNotAvailable)
    }

    struct CurrentAdParameters {
        var duration: String
        var position: String
        var dimension: String
        var allowPause: String
        var allowClose: String
        var closeDelay: String

        static let initial = Self(duration: valueNotAvailable,
                                  position: valueNotAvailable,
                                  dimension: valueNotAvailable,
                                  allowPause: valueNotAvailable,
                                  allowClose: valueNotAvailable,
                                  closeDelay: valueNotAvailable)
    }
}
