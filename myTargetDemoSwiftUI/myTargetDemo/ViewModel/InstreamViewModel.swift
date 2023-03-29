//
//  InstreamViewModel.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 15.12.2022.
//  Copyright © 2022 VK. All rights reserved.
//

import Foundation
import MyTargetSDK

final class InstreamViewModel: NSObject, ObservableObject {

	static let mainVideoDuration = 30.0
	private static let mainVideoUrl = "https://r.mradx.net/img/1A/E16A8A.mp4"
	private static let valueNotAvailable = "n/a"

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

	private let slotId: UInt
	private var instreamAd: MTRGInstreamAd?
	private var mainVideoPosition: TimeInterval = 0
	private var midpoints: [Double] = []
	private var timer: Timer?
	private var shouldSkipAllAds: Bool = false

	private(set) var mainVideoView: VideoPlayerView
	private(set) var adPlayerView: UIView?

	@Published var progressPosition: TimeInterval = 0
	@Published var progressPoints = [Double]()

	@Published private(set) var fullscreen: String = valueNotAvailable
	@Published private(set) var quality: String = valueNotAvailable
	@Published private(set) var timeout: String = valueNotAvailable
	@Published private(set) var volume: String = valueNotAvailable
	
	@Published private(set) var duration: String = valueNotAvailable
	@Published private(set) var position: String = valueNotAvailable
	@Published private(set) var dimension: String = valueNotAvailable
	@Published private(set) var allowPause: String = valueNotAvailable
	@Published private(set) var allowClose: String = valueNotAvailable
	@Published private(set) var closeDelay: String = valueNotAvailable

	@Published private(set) var status: String = State.notLoaded.status
	@Published private(set) var ctaTitle: String = "Proceed"

	@Published private(set) var isLoadButtonDisabled = false
	@Published private(set) var isPlayButtonDisabled = false
	@Published private(set) var isPauseButtonDisabled = false
	@Published private(set) var isResumeButtonDisabled = false
	@Published private(set) var isStopButtonDisabled = false

	@Published private(set) var isPlayerButtonsHidden = true

	@Published private(set) var isAdVideoActive = false
	@Published private(set) var isMainVideoActive = false

	@Published var currentInstreamViewController: InstreamViewController?

	private var state: State {
		didSet {
			applyCurrentState()
		}
	}

	init(slotId: UInt) {
		let mainVideoView = VideoPlayerView()
		self.mainVideoView = mainVideoView
		self.slotId = slotId
		self.state = .notLoaded
		super.init()
		setup()
		applyCurrentState()
	}

	private func setup() {
		mainVideoView.delegate = self

		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	// MARK: - Actions

	@objc private func applicationWillResignActive(_ notification: Notification) {
		pauseVideo()
	}

	@objc private func applicationDidBecomeActive(_ notification: Notification) {
		resumeVideo()
	}

	func loadButtonTapped() {
		loadInstreamAd()
	}

	func playButtonTapped() {
		playVideo()
	}

	func pauseButtonTapped() {
		pauseVideo()
	}

	func resumeButtonTapped() {
		resumeVideo()
	}

	func stopButtonTapped() {
		stopVideo()
	}

	func skipButtonTapped() {
		skipBanner()
	}

	func skipAllButtonTapped() {
		skipAllBanners()
	}

	func clickButtonTapped() {
		guard let controller = currentInstreamViewController else {
			return
		}
		handleClick(with: controller)
	}

	func viewDidDisappear() {
		pauseVideo()
	}

	// MARK: - Private

	private func instreamParametersClear() {
		fullscreen = InstreamViewModel.valueNotAvailable
		quality = InstreamViewModel.valueNotAvailable
		timeout = InstreamViewModel.valueNotAvailable
		volume = InstreamViewModel.valueNotAvailable
	}

	private func currentAdParametersClear() {
		duration = InstreamViewModel.valueNotAvailable
		position = InstreamViewModel.valueNotAvailable
		dimension = InstreamViewModel.valueNotAvailable
		allowPause = InstreamViewModel.valueNotAvailable
		allowClose = InstreamViewModel.valueNotAvailable
		closeDelay = InstreamViewModel.valueNotAvailable
	}

	private func applyCurrentState() {
		isAdVideoActive = false
		isMainVideoActive = false
		isPlayerButtonsHidden = true

		isPlayButtonDisabled = true
		isPauseButtonDisabled = true
		isResumeButtonDisabled = true
		isStopButtonDisabled = true
		isLoadButtonDisabled = false

		status = state.status

		switch state {
		case .notLoaded:
			break
		case .loading:
			isLoadButtonDisabled = true

			instreamParametersClear()
			currentAdParametersClear()
		case .noAd:
			isPlayButtonDisabled = false
		case .ready:
			isPlayButtonDisabled = false
		case .preparing(let video):
			switch video {
			case .main:
				isAdVideoActive = false
				isMainVideoActive = true

				currentAdParametersClear()
			case .preroll, .midroll, .postroll:
				isAdVideoActive = true
				isMainVideoActive = false
			}
		case .playing(let video):
			isPauseButtonDisabled = false
			isStopButtonDisabled = false

			switch video {
			case .main:
				isAdVideoActive = false
				isMainVideoActive = true
			case .preroll, .midroll, .postroll:
				isAdVideoActive = true
				isMainVideoActive = false
				isPlayerButtonsHidden = false
			}
		case .onPause(let video):
			isResumeButtonDisabled = false
			isStopButtonDisabled = false

			switch video {
			case .main:
				isAdVideoActive = false
				isMainVideoActive = true
			case .preroll, .midroll, .postroll:
				isAdVideoActive = true
				isMainVideoActive = false
				isPlayerButtonsHidden = false
			}
		case .complete:
			currentAdParametersClear()
		case .error(_):
			isPlayButtonDisabled = false
		}
	}

	// MARK: - Instream ad

	private func loadInstreamAd() {
		state = .loading
		mainVideoView.stop()
		mainVideoPosition = 0
		midpoints.removeAll()
		progressPosition = mainVideoPosition
		progressPoints = midpoints
		shouldSkipAllAds = false

		instreamAd?.stop()
		instreamAd?.player?.adPlayerView.removeFromSuperview()
		instreamAd = nil

		instreamAd = MTRGInstreamAd(slotId: slotId)
		instreamAd?.useDefaultPlayer()
		instreamAd?.delegate = self

		instreamAd?.configureMidpoints(forVideoDuration: InstreamViewModel.mainVideoDuration)

		adPlayerView = instreamAd?.player?.adPlayerView

		instreamAd?.customParams.age = 100
		instreamAd?.customParams.gender = MTRGGenderUnknown

		instreamAd?.load()
	}

	private func handleClick(with controller: UIViewController) {
		instreamAd?.handleClick(with: controller)
	}

	private func skipBanner() {
		instreamAd?.skipBanner()
	}

	private func skipAllBanners() {
		shouldSkipAllAds = true
		midpoints.removeAll()
		instreamAd?.skip()
	}

	// MARK: - Video

	private func playVideo() {
		switch state {
		case .ready:
			state = .preparing(.preroll)
			instreamAd?.startPreroll()
		case .noAd, .error:
			playMainVideo()
		default:
			break
		}
	}

	private func pauseVideo() {
		guard case .playing(let video) = state else {
			return
		}

		state = .onPause(video)
		if video == .main {
			mainVideoView.pause()
		} else {
			instreamAd?.pause()
		}
	}

	private func resumeVideo() {
		guard case .onPause(let video) = state else {
			return
		}

		state = .playing(video)
		if video == .main {
			mainVideoView.resume()
		} else {
			instreamAd?.resume()
		}
	}

	private func stopVideo() {
		switch state {
		case .playing(let video), .onPause(let video):
			if video == .main {
				mainVideoPosition = InstreamViewModel.mainVideoDuration
				progressPosition = mainVideoPosition
				mainVideoView.finish()
			} else {
				instreamAd?.stop()
			}
		default:
			break
		}
	}

	private func playMainVideo() {
		guard let url = URL(string: InstreamViewModel.mainVideoUrl) else {
			return
		}

		state = .preparing(.main)
		mainVideoView.start(with: url, position: mainVideoPosition)
	}

	private func playMidroll(at midpoint: Double) {
		state = .onPause(.main)
		mainVideoView.pause()

		state = .preparing(.midroll)
		midpoints.removeFirst()
		instreamAd?.startMidroll(withPoint: NSNumber(value: midpoint))
	}

	private func playPostroll() {
		state = .preparing(.postroll)
		instreamAd?.startPostroll()
	}

	// MARK: - Timer

	private func startTimer() {
		stopTimer()
		let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
			guard let self = self, self.state == .playing(.main) else {
				return
			}

			let currentTime = self.mainVideoView.currentTime

			guard currentTime <= InstreamViewModel.mainVideoDuration else {
				self.stopTimer()
				self.stopVideo()
				return
			}

			self.mainVideoPosition = currentTime
			self.progressPosition = currentTime

			if let midpoint = self.midpoints.first(where: { $0 < currentTime }) {
				self.stopTimer()
				self.playMidroll(at: midpoint)
			}
		}
		self.timer = timer
		RunLoop.current.add(timer, forMode: .common)
	}

	private func stopTimer() {
		timer?.invalidate()
		timer = nil
	}

}

extension InstreamViewModel: MTRGInstreamAdDelegate {

	func onLoad(with instreamAd: MTRGInstreamAd) {
		midpoints = instreamAd.midpoints.map { $0.doubleValue }
		progressPoints = midpoints

		fullscreen = "\(instreamAd.fullscreen)"
		quality = "\(instreamAd.videoQuality)"
		timeout = "\(instreamAd.loadingTimeout)"
		volume = String(format: "%.2f", instreamAd.volume)

		state = .ready
		print("InstreamViewModel: onLoad() called")
	}

	func onNoAd(withReason reason: String, instreamAd: MTRGInstreamAd) {
		self.instreamAd = nil

		state = .noAd
		print("InstreamViewModel: onNoAd(\(reason)) called")
	}

	func onError(withReason reason: String, instreamAd: MTRGInstreamAd) {
		state = .error(reason: reason)
		print("InstreamViewModel: onError(\(reason)) called")
	}

	func onBannerStart(_ banner: MTRGInstreamAdBanner, instreamAd: MTRGInstreamAd) {
		duration = String(format: "%.2f", banner.duration)
		position = "0"
		dimension = String(format: "%.fx%.f", banner.size.width, banner.size.height)
		allowPause = "\(banner.allowPause)"
		allowClose = "\(banner.allowClose)"
		closeDelay = String(format: "%.2f", banner.allowCloseDelay)

		guard case .preparing(let video) = state else {
			return
		}

		state = .playing(video)
		ctaTitle = banner.ctaText
		print("InstreamViewModel: onBannerStart() called")
	}

	func onBannerComplete(_ banner: MTRGInstreamAdBanner, instreamAd: MTRGInstreamAd) {
		print("InstreamViewModel: onBannerComplete() called")
	}

	func onBannerTimeLeftChange(_ timeLeft: TimeInterval, duration: TimeInterval, instreamAd: MTRGInstreamAd) {
		position = String(format: "%.2f", duration - timeLeft)
		print("InstreamViewModel: onBannerTimeLeftChange(" + String(format: "timeLeft: %.2f", timeLeft) + ", " + String(format: "duration: %.2f", duration) + ") called")
	}

	func onComplete(withSection section: String, instreamAd: MTRGInstreamAd) {
		print("InstreamViewModel: onComplete() called")

		switch state {
		case .preparing(let video), .playing(let video), .onPause(let video):
			switch video {
			case .postroll:
				state = .complete
			default:
				playMainVideo()
			}
		default:
			break
		}
	}

	func onShowModal(with instreamAd: MTRGInstreamAd) {
		pauseVideo()
		print("InstreamViewModel: onShowModal() called")
	}

	func onDismissModal(with instreamAd: MTRGInstreamAd) {
		resumeVideo()
		print("InstreamViewModel: onDismissModal() called")
	}

	func onLeaveApplication(with instreamAd: MTRGInstreamAd) {
		print("InstreamViewModel: onLeaveApplication() called")
	}

}

// MARK: - VideoPlayerViewDelegate

extension InstreamViewModel: VideoPlayerViewDelegate {

	func onVideoStarted(url: URL) {
		print("InstreamViewModel: onVideoStarted() called")
		guard state == .preparing(.main) else {
			return
		}

		state = .playing(.main)
		startTimer()
	}

	func onVideoComplete() {
		print("InstreamViewModel: onVideoComplete() called")
		guard state == .playing(.main) else {
			return
		}

		stopTimer()

		if shouldSkipAllAds || instreamAd == nil {
			state = .complete
		} else {
			playPostroll()
		}
	}

	func onVideoFinished(error: String) {
		state = .error(reason: error)
		print("InstreamViewModel: onVideoFinished() called, error: \(error)")
	}

}

// MARK: - Status for state

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
