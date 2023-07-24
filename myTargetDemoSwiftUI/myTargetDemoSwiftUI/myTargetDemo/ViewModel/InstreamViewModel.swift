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

    @Published private(set) var instreamParameters: InstreamParameters = .initial

    @Published private(set) var currentAdParameters: CurrentAdParameters = .initial

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
	    self.mainVideoView = VideoPlayerView()
	    self.slotId = slotId
	    self.state = .notLoaded
	    super.init()
	    setup()
	    applyCurrentState()
    }

    private func setup() {
	    mainVideoView.delegate = self

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - Actions

    @objc private func appWillResignActive() {
	    pauseVideo()
    }

    @objc private func appDidBecomeActive() {
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
        instreamParameters = .initial
    }

    private func currentAdParametersClear() {
        currentAdParameters = .initial
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
    	    applyPreparingState(for: video)
	    case .playing(let video):
    	    applyPlayingState(for: video)
	    case .onPause(let video):
    	    applyPauseState(for: video)
	    case .complete:
    	    currentAdParametersClear()
	    case .error:
    	    isPlayButtonDisabled = false
	    }
    }

    private func applyPreparingState(for video: State.Video) {
        switch video {
        case .main:
            isAdVideoActive = false
            isMainVideoActive = true

            currentAdParametersClear()
        case .preroll, .midroll, .postroll:
            isAdVideoActive = true
            isMainVideoActive = false
        }
    }

    private func applyPlayingState(for video: State.Video) {
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
    }

    private func applyPauseState(for video: State.Video) {
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

// MARK: - MTRGInstreamAdDelegate

extension InstreamViewModel: MTRGInstreamAdDelegate {

    func onLoad(with instreamAd: MTRGInstreamAd) {
	    midpoints = instreamAd.midpoints.map { $0.doubleValue }
	    progressPoints = midpoints

        instreamParameters.fullscreen = "\(instreamAd.fullscreen)"
        instreamParameters.quality = "\(instreamAd.videoQuality)"
        instreamParameters.timeout = "\(instreamAd.loadingTimeout)"
        instreamParameters.volume = String(format: "%.2f", instreamAd.volume)

	    state = .ready
	    print("InstreamViewModel: onLoad() called")
    }

    func onLoadFailed(error: Error, instreamAd: MTRGInstreamAd) {
        self.instreamAd = nil

        state = .noAd
        print("InstreamViewModel: onLoadFailed(\(error)) called")
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
        currentAdParameters.duration = String(format: "%.2f", banner.duration)
        currentAdParameters.position = "0"
        currentAdParameters.dimension = String(format: "%.fx%.f", banner.size.width, banner.size.height)
        currentAdParameters.allowPause = "\(banner.allowPause)"
        currentAdParameters.allowClose = "\(banner.allowClose)"
        currentAdParameters.closeDelay = String(format: "%.2f", banner.allowCloseDelay)

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
        currentAdParameters.position = String(format: "%.2f", duration - timeLeft)
	    print("InstreamViewModel: onBannerTimeLeftChange(" +
              String(format: "timeLeft: %.2f", timeLeft) + ", " +
              String(format: "duration: %.2f", duration) + ") called")
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
