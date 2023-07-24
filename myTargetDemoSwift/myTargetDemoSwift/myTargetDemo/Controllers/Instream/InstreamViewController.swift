//
//  InstreamViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 19.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class InstreamViewController: UIViewController {

    private let slotId: UInt?
    private let query: [String: String]?

    private lazy var notificationView: NotificationView = .create(view: view)

    private var instreamAd: MTRGInstreamAd?
    private var mainVideoPosition: TimeInterval = 0
    private var midpoints: [Double] = []
    private var timer: Timer?
    private var shouldSkipAllAds: Bool = false

    private var customView: InstreamView {
        // swiftlint:disable:next force_cast
        view as! InstreamView
    }
    private var state: InstreamView.State {
        get {
            customView.state
        }
        set {
            customView.state = newValue
        }
    }

    private static let mainVideoUrl = "https://r.mradx.net/img/1A/E16A8A.mp4"
    static let mainVideoDuration = 30.0

    init(slotId: UInt? = nil, query: [String: String]? = nil) {
        self.slotId = slotId
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = InstreamView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "In-stream video"

        customView.mainVideoView.delegate = self

        customView.ctaButton.addTarget(self, action: #selector(ctaButtonTap(_:)), for: .touchUpInside)
        customView.skipButton.addTarget(self, action: #selector(skipButtonTap(_:)), for: .touchUpInside)
        customView.skipAllButton.addTarget(self, action: #selector(skipAllButtonTap(_:)), for: .touchUpInside)
        customView.adChoicesButton.addTarget(self, action: #selector(adChoicesButtonTap(_:)), for: .touchUpInside)

        customView.playButton.addTarget(self, action: #selector(playButtonTap(_:)), for: .touchUpInside)
        customView.pauseButton.addTarget(self, action: #selector(pauseButtonTap(_:)), for: .touchUpInside)
        customView.resumeButton.addTarget(self, action: #selector(resumeButtonTap(_:)), for: .touchUpInside)
        customView.stopButton.addTarget(self, action: #selector(stopButtonTap(_:)), for: .touchUpInside)
        customView.loadButton.addTarget(self, action: #selector(loadButtonTap(_:)), for: .touchUpInside)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        state = .notLoaded
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard isMovingFromParent || isBeingDismissed else {
            return
        }

        pauseVideo()
    }

    // MARK: - Instream ad

    private func loadInstreamAd() {
        state = .loading
        customView.mainVideoView.stop()
        mainVideoPosition = 0
        midpoints.removeAll()
        customView.progressView.position = mainVideoPosition
        customView.progressView.points = midpoints
        shouldSkipAllAds = false

        instreamAd?.stop()
        instreamAd?.player?.adPlayerView.removeFromSuperview()
        instreamAd = nil

        instreamAd = MTRGInstreamAd(slotId: slotId ?? Slot.instreamVideo.id, menuFactory: AlertMenuFactory())
        instreamAd?.useDefaultPlayer()
        instreamAd?.delegate = self

        instreamAd?.configureMidpoints(forVideoDuration: InstreamViewController.mainVideoDuration)

        customView.adPlayerView = instreamAd?.player?.adPlayerView

        instreamAd?.customParams.age = 100
        instreamAd?.customParams.gender = MTRGGenderUnknown
        query?.forEach { instreamAd?.customParams.setCustomParam($0.value, forKey: $0.key) }

        instreamAd?.load()
    }

    private func showBannerModal() {
        instreamAd?.handleClick(with: self)
    }

    private func skipBanner() {
        instreamAd?.skipBanner()
    }

    private func skipAll() {
        shouldSkipAllAds = true
        midpoints.removeAll()
        instreamAd?.skip()
    }

    private func showAdChoicesMenu(sourceView: UIView?) {
        instreamAd?.handleAdChoicesClick(with: self, sourceView: sourceView)
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
            customView.mainVideoView.pause()
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
            customView.mainVideoView.resume()
        } else {
            instreamAd?.resume()
        }
    }

    private func stopVideo() {
        switch state {
        case .playing(let video), .onPause(let video):
            if video == .main {
                mainVideoPosition = InstreamViewController.mainVideoDuration
                customView.progressView.position = mainVideoPosition
                customView.mainVideoView.finish()
            } else {
                instreamAd?.stop()
            }
        default:
            break
        }
    }

    private func playMainVideo() {
        guard let url = URL(string: InstreamViewController.mainVideoUrl) else {
            return
        }

        state = .preparing(.main)
        customView.mainVideoView.start(with: url, position: mainVideoPosition)
    }

    private func playMidroll(at midpoint: Double) {
        state = .onPause(.main)
        customView.mainVideoView.pause()

        state = .preparing(.midroll)
        midpoints.removeFirst()
        instreamAd?.startMidroll(withPoint: NSNumber(value: midpoint))
    }

    private func playPostroll() {
        state = .preparing(.postroll)
        instreamAd?.startPostroll()
    }

    // MARK: - Actions

    @objc private func ctaButtonTap(_ sender: PlayerAdButton) {
        showBannerModal()
    }

    @objc private func skipButtonTap(_ sender: PlayerAdButton) {
        skipBanner()
    }

    @objc private func skipAllButtonTap(_ sender: PlayerAdButton) {
        skipAll()
    }

    @objc private func adChoicesButtonTap(_ sender: UIButton) {
        showAdChoicesMenu(sourceView: sender)
    }

    @objc private func playButtonTap(_ sender: CustomButton) {
        playVideo()
    }

    @objc private func pauseButtonTap(_ sender: CustomButton) {
        pauseVideo()
    }

    @objc private func resumeButtonTap(_ sender: CustomButton) {
        resumeVideo()
    }

    @objc private func stopButtonTap(_ sender: CustomButton) {
        stopVideo()
    }

    @objc private func loadButtonTap(_ sender: CustomButton) {
        loadInstreamAd()
    }

    @objc private func applicationWillResignActive(_ notification: Notification) {
        pauseVideo()
    }

    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        resumeVideo()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.state == .playing(.main) else {
                return
            }

            let currentTime = self.customView.mainVideoView.currentTime

            guard currentTime <= InstreamViewController.mainVideoDuration else {
                self.stopTimer()
                self.stopVideo()
                return
            }

            self.mainVideoPosition = currentTime
            self.customView.progressView.position = currentTime

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

extension InstreamViewController: MTRGInstreamAdDelegate {

    func onLoad(with instreamAd: MTRGInstreamAd) {
        midpoints = instreamAd.midpoints.map { $0.doubleValue }
        customView.progressView.points = midpoints

        customView.instreamParametersInfoView[.fullscreen] = "\(instreamAd.fullscreen)"
        customView.instreamParametersInfoView[.quality] = "\(instreamAd.videoQuality)"
        customView.instreamParametersInfoView[.timeout] = "\(instreamAd.loadingTimeout)"
        customView.instreamParametersInfoView[.volume] = String(format: "%.2f", instreamAd.volume)

        state = .ready
        notificationView.showMessage("onLoad() called")
    }

    func onLoadFailed(error: Error, instreamAd: MTRGInstreamAd) {
        self.instreamAd = nil

        state = .noAd
        notificationView.showMessage("onLoadFailed(\(error)) called")
    }

    func onError(withReason reason: String, instreamAd: MTRGInstreamAd) {
        state = .error(reason: reason)
        notificationView.showMessage("onError(\(reason)) called")
    }

    func onBannerStart(_ banner: MTRGInstreamAdBanner, instreamAd: MTRGInstreamAd) {
        customView.currentAdParametersInfoView[.duration] = String(format: "%.2f", banner.duration)
        customView.currentAdParametersInfoView[.position] = "0"
        customView.currentAdParametersInfoView[.dimension] = String(format: "%.fx%.f", banner.size.width, banner.size.height)
        customView.currentAdParametersInfoView[.allowPause] = "\(banner.allowPause)"
        customView.currentAdParametersInfoView[.allowClose] = "\(banner.allowClose)"
        customView.currentAdParametersInfoView[.closeDelay] = String(format: "%.2f", banner.allowCloseDelay)

        guard case .preparing(let video) = state else {
            return
        }

        state = .playing(video)
        customView.ctaButton.setTitle(banner.ctaText, for: .normal)
        customView.advertisingLabel.text = banner.advertisingLabel
        customView.adChoicesButton.setImage(banner.adChoicesImage, for: .normal)
        notificationView.showMessage("onBannerStart() called")
    }

    func onBannerComplete(_ banner: MTRGInstreamAdBanner, instreamAd: MTRGInstreamAd) {
        notificationView.showMessage("onBannerComplete() called")
    }

    func onBannerTimeLeftChange(_ timeLeft: TimeInterval, duration: TimeInterval, instreamAd: MTRGInstreamAd) {
        customView.currentAdParametersInfoView[.position] = String(format: "%.2f", duration - timeLeft)
        print("onBannerTimeLeftChange(" + String(format: "timeLeft: %.2f", timeLeft) + ", " + String(format: "duration: %.2f", duration) + ") called")
    }

    func onBannerShouldClose(_ banner: MTRGInstreamAdBanner, instreamAd: MTRGInstreamAd) {
        skipBanner()
    }

    func onComplete(withSection section: String, instreamAd: MTRGInstreamAd) {
        notificationView.showMessage("onComplete() called")

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
        notificationView.showMessage("onShowModal() called")
    }

    func onDismissModal(with instreamAd: MTRGInstreamAd) {
        resumeVideo()
        notificationView.showMessage("onDismissModal() called")
    }

    func onLeaveApplication(with instreamAd: MTRGInstreamAd) {
        notificationView.showMessage("onLeaveApplication() called")
    }

}

// MARK: - VideoPlayerViewDelegate

extension InstreamViewController: VideoPlayerViewDelegate {

    func onVideoStarted(url: URL) {
        guard state == .preparing(.main) else {
            return
        }

        state = .playing(.main)
        startTimer()
    }

    func onVideoComplete() {
        guard state == .playing(.main) || state == .onPause(.main) else {
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
        notificationView.showMessage("Error: \(error)")
    }

}
