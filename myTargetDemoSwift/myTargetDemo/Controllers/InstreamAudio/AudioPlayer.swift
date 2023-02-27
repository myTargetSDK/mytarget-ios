//
//  AudioPlayer.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 06.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import Foundation
import AVFAudio
import MyTargetSDK

final class AudioPlayer: NSObject, MTRGInstreamAudioAdPlayer {
    private let loader: Loader = .init()
    private var player: AVAudioPlayer?
    private var downloadTask: DownloadTask?
    private var seekToTime: TimeInterval = 0

    weak var adPlayerDelegate: MTRGInstreamAudioAdPlayerDelegate?

    var adAudioDuration: TimeInterval {
        return player?.duration ?? 0
    }

    var adAudioTimeElapsed: TimeInterval {
        return player?.currentTime ?? 0
    }

    var volume: Float = 1 {
        didSet {
            player?.volume = volume
        }
    }

    func playAdAudio(with url: URL) {
        playAdAudio(with: url, position: 0)
    }

    func playAdAudio(with url: URL, position: TimeInterval) {
        if let player = player, let currentTask = downloadTask, currentTask.url == url {
            player.pause()
            player.currentTime = seekToTime
            player.play()
            return
        }

        reset()

        seekToTime = position
        downloadTask = loader.download(url: url) { [weak self] result in
            switch result {
            case .success(let localAudio):
                self?.startPlayer(with: localAudio)
            case .failure(let error):
                self?.reset()
                self?.adPlayerDelegate?.onAdAudioError(withReason: error.localizedDescription)
            }
        }
    }

    func pauseAdAudio() {
        player?.pause()
        adPlayerDelegate?.onAdAudioPause()
    }

    func resumeAdAudio() {
        player?.play()
        adPlayerDelegate?.onAdAudioResume()
    }

    func stopAdAudio() {
        reset()
        adPlayerDelegate?.onAdAudioStop()
    }

    // MARK: - Private

    private func startPlayer(with localAudio: URL) {
        guard let player = try? AVAudioPlayer(contentsOf: localAudio) else {
            reset()
            adPlayerDelegate?.onAdAudioError(withReason: "Can't create AVAudioPlayer")
            return
        }

        player.volume = volume
        player.delegate = self
        player.currentTime = seekToTime
        player.play()
        self.player = player
        adPlayerDelegate?.onAdAudioStart()
    }

    private func reset() {
        downloadTask?.cancel()
        downloadTask = nil

        player?.pause()
        player = nil
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        reset()

        if flag {
            adPlayerDelegate?.onAdAudioComplete()
        } else {
            adPlayerDelegate?.onAdAudioError(withReason: "Player did finish playing with error")
        }
    }

}
