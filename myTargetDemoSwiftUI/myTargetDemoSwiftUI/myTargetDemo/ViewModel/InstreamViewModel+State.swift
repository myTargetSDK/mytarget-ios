//
//  InstreamViewModel+State.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 15.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation

extension InstreamViewModel {
    enum State: Equatable {
        case notLoaded
        case loading
        case noAd
        case ready
        case preparing(Video)
        case playing(Video)
        case onPause(Video)
        case complete
        case error(reason: String)

        enum Video: String {
            case main = "Main video"
            case preroll = "Preroll"
            case midroll = "Midroll"
            case postroll = "Postroll"
        }
    }
}

extension InstreamViewModel.State {
    var status: String {
        switch self {
        case .notLoaded:
            return "Not loaded"
        case .loading:
            return "Loading..."
        case .noAd:
            return "No ad"
        case .ready:
            return "Ready"
        case .complete:
            return "Complete"
        case .preparing(let video):
            return "\(video.rawValue) loading..."
        case .playing(let video):
            return video.rawValue
        case .onPause(let video):
            return "\(video.rawValue) on pause"
        case .error(let reason):
            return reason
        }
    }
}
