//
//  VideoPlayerView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 01/08/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPlayerViewDelegate: AnyObject {
	func onVideoStarted(url: URL)
	func onVideoComplete()
	func onVideoFinished(error: String)
}

final class VideoPlayerView: UIView {
	weak var delegate: VideoPlayerViewDelegate?

	private var position: TimeInterval = 0.0
	private var isPaused = false

	private var _currentTime: TimeInterval = 0.0
	var currentTime: TimeInterval {
		get {
			guard let player = player else {
                return _currentTime
            }

			return CMTimeGetSeconds(player.currentTime())
		}
		set {
			_currentTime = newValue
			guard let player = player else {
                return
            }

			player.seek(to: CMTimeMakeWithSeconds(_currentTime, preferredTimescale: 1))
		}
	}

	private var _volume: Float = 1.0
	var volume: Float {
		get {
			guard let player = player else {
                return _volume
            }

			return player.volume
		}
		set {
			_volume = newValue
			guard let player = player else {
                return
            }

			player.volume = _volume
		}
	}

	private var url: URL?
	private var asset: AVURLAsset?
	private var playerItem: AVPlayerItem?

	private var player: AVPlayer? {
		get {
			guard let layer = layer as? AVPlayerLayer else {
                return nil
            }

			return layer.player
		}
		set {
			guard let layer = layer as? AVPlayerLayer else {
                return
            }

			layer.player = newValue
		}
	}

	private static var playerItemContext = 0
	private let requiredAssetKeys = ["playable"]

	private var playerItemDuration: TimeInterval {
        guard let playerItem = playerItem, playerItem.status == .readyToPlay, CMTIME_IS_VALID(playerItem.duration) else {
            return 0.0
        }

        let duration = CMTimeGetSeconds(playerItem.duration)
        return duration.isFinite ? duration : 0.0
	}

	deinit {
		stop()
	}

	override final class var layerClass: AnyClass {
		return AVPlayerLayer.self
	}

// MARK: - public

	func start(with url: URL, position: TimeInterval) {
		self.position = position
		if let player = player, isPaused, let internalURL = self.url, internalURL.absoluteString == url.absoluteString {
			player.play()
            delegateOnVideoStarted(url: url)
			return
		}

		self.url = url
		isPaused = false
		asset = AVURLAsset(url: url)
		guard let asset = asset else {
            return
        }

		asset.loadValuesAsynchronously(forKeys: requiredAssetKeys) {
			DispatchQueue.main.async {
				self.prepareToPlay()
			}
		}
	}

	func pause() {
		guard let player = player else {
            return
        }

		player.pause()
		isPaused = true
	}

	func resume() {
		guard let player = player else {
            return
        }

		player.play()
		isPaused = false
	}

	func stop() {
		player?.pause()
		deletePlayerItem()
		deletePlayer()
	}

	func finish() {
		stop()
		delegateOnVideoComplete()
	}

// MARK: - private

	private func prepareToPlay() {
		guard let asset = asset else {
            return
        }

		requiredAssetKeys.forEach { (key: String) in
			var error: NSError?
			let keyStatus = asset.statusOfValue(forKey: key, error: &error)
			if keyStatus == .failed {
				stop()
				delegateOnVideoFinished(error: "Item cannot be played, status failed")
			}
		}

		if !asset.isPlayable {
			stop()
			delegateOnVideoFinished(error: "Item cannot be played")
			return
		}

		deletePlayerItem()
		createPlayerItem()

		deletePlayer()
		createPlayer()

		guard let player = player else {
            return
        }

		player.seek(to: CMTimeMakeWithSeconds(position, preferredTimescale: 1))
		player.play()
	}

	private func createPlayerItem() {
		guard let asset = asset else {
            return
        }

		playerItem = AVPlayerItem(asset: asset)
		guard let playerItem = playerItem else {
            return
        }

		playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.initial, .new], context: &VideoPlayerView.playerItemContext)
		NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
	}

	private func deletePlayerItem() {
		guard let playerItem = playerItem else {
            return
        }

		playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
		NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
		self.playerItem = nil
	}

	private func createPlayer() {
		guard let playerItem = playerItem else {
            return
        }

		player = AVPlayer(playerItem: playerItem)
		guard let player = player else {
            return
        }
		player.volume = volume
	}

	private func deletePlayer() {
		guard let player = player else {
            return
        }

		player.pause()
		self.player = nil
	}

// MARK: - observers

	@objc private func playerItemDidReachEnd(notification: Notification) {
		guard let object = notification.object as? AVPlayerItem, let playerItem = playerItem, object == playerItem else {
            return
        }

		stop()
		delegateOnVideoComplete()
	}

    // swiftlint:disable:next block_based_kvo
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		guard context == &VideoPlayerView.playerItemContext else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			return
		}
		guard keyPath == #keyPath(AVPlayerItem.status) else {
            return
        }

        let statusNumber = change?[.newKey] as? NSNumber
        let status = statusNumber.flatMap {
            AVPlayerItem.Status(rawValue: $0.intValue)
        } ?? .unknown

		playerItemStatusChanged(status)
	}

    private func playerItemStatusChanged(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            let duration = playerItemDuration
            print("Player item status ---> Ready, duration = \(duration)")
            if duration == 0 {
                stop()
                delegateOnVideoFinished(error: "Player item duration = 0")
            } else {
                // Success
                guard let url = url else {
                    return
                }
                delegateOnVideoStarted(url: url)
            }
        case .failed:
            print("Player item status ---> Failed")
            stop()
            delegateOnVideoFinished(error: "Player item status is failed")
        case .unknown:
            print("Player item status ---> Unknown")
        @unknown default:
            break
        }
    }

// MARK: - delegates

	private func delegateOnVideoStarted(url: URL) {
		delegate?.onVideoStarted(url: url)
	}

	private func delegateOnVideoComplete() {
		delegate?.onVideoComplete()
	}

	private func delegateOnVideoFinished(error: String) {
		delegate?.onVideoFinished(error: error)
	}
}
