//
//  InstreamAudioViewController.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 02.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class InstreamAudioViewController: UIViewController {

    private let slotId: UInt?
    private let query: [String: String]?

    private static let mainAudioUrl = "https://r.mradx.net/img/E5/E8EF84.mp3"
    static let mainAudioDuration: TimeInterval = 44.96

    private lazy var notificationView: NotificationView = .create(view: view)

    private var mainAudioPosition: TimeInterval = 0
    private var instreamAudioAd: MTRGInstreamAudioAd?
    private let player: AudioPlayer = .init()
    private var timer: Timer?
    private var midpoints: [TimeInterval] = []
    private var shouldSkipAllAds: Bool = false

    private var customView: InstreamAudioView {
        // swiftlint:disable:next force_cast
        view as! InstreamAudioView
    }
    private var state: InstreamAudioView.State {
        get {
            customView.state
        }
        set {
            customView.state = newValue
        }
    }

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
        view = InstreamAudioView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "In-stream audio"

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

        pauseAudio()
    }

    // MARK: - Instream Audio ad

    private func loadAd() {
        state = .loading
        player.stopAdAudio()
        mainAudioPosition = 0
        midpoints.removeAll()
        customView.progressView.position = mainAudioPosition
        customView.progressView.points = midpoints
        shouldSkipAllAds = false

        instreamAudioAd?.stop()
        instreamAudioAd = nil

        instreamAudioAd = MTRGInstreamAudioAd(slotId: slotId ?? Slot.instreamAudio.id, menuFactory: AlertMenuFactory())
        instreamAudioAd?.delegate = self

        instreamAudioAd?.configureMidpoints(forAudioDuration: Self.mainAudioDuration)

        instreamAudioAd?.customParams.age = 100
        instreamAudioAd?.customParams.gender = MTRGGenderUnknown
        query?.forEach { instreamAudioAd?.customParams.setCustomParam($0.value, forKey: $0.key) }

        instreamAudioAd?.load()
    }

    private func handleCompanionClick() {
        guard
            let instreamAudioAd = instreamAudioAd,
            let companionBanner = instreamAudioAd.currentBanner?.companionBanners.first
        else {
            return
        }

        instreamAudioAd.handleCompanionClick(companionBanner, with: self)
    }

    private func skipBanner() {
        instreamAudioAd?.skipBanner()
    }

    private func skipAll() {
        shouldSkipAllAds = true
        midpoints.removeAll()
        instreamAudioAd?.skip()
    }

    private func showAdChoicesMenu(sourceView: UIView?) {
        instreamAudioAd?.handleAdChoicesClick(with: self, sourceView: sourceView)
    }

    // MARK: - Actions

    @objc private func ctaButtonTap(_ sender: PlayerAdButton) {
        handleCompanionClick()
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
        playAudio()
    }

    @objc private func pauseButtonTap(_ sender: CustomButton) {
        pauseAudio()
    }

    @objc private func resumeButtonTap(_ sender: CustomButton) {
        resumeAudio()
    }

    @objc private func stopButtonTap(_ sender: CustomButton) {
        stopAudio()
    }

    @objc private func loadButtonTap(_ sender: CustomButton) {
        loadAd()
    }

    @objc private func applicationWillResignActive(_ notification: Notification) {
        pauseAudio()
    }

    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        resumeAudio()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.state == .playing(.main) else {
                return
            }

            let currentTime = self.player.adAudioTimeElapsed

            guard currentTime <= InstreamAudioViewController.mainAudioDuration else {
                self.stopTimer()
                self.stopAudio()
                return
            }

            self.mainAudioPosition = currentTime
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

    // MARK: - Audio

    private func playAudio() {
        switch state {
        case .ready:
            state = .preparing(.preroll)
            instreamAudioAd?.player = player
            instreamAudioAd?.startPreroll()
        case .noAd, .error:
            playMainAudio()
        default:
            break
        }
    }

    private func playMainAudio() {
        guard let url = URL(string: Self.mainAudioUrl) else {
            return
        }

        state = .preparing(.main)
        player.adPlayerDelegate = self
        player.playAdAudio(with: url, position: mainAudioPosition)
    }

    private func pauseAudio() {
        guard case .playing(let audio) = state else {
            return
        }

        state = .onPause(audio)
        if audio == .main {
            player.pauseAdAudio()
        } else {
            instreamAudioAd?.pause()
        }
    }

    private func resumeAudio() {
        guard case .onPause(let audio) = state else {
            return
        }

        state = .playing(audio)
        if audio == .main {
            player.resumeAdAudio()
        } else {
            instreamAudioAd?.resume()
        }
    }

    private func stopAudio() {
        switch state {
        case .playing(let audio), .onPause(let audio):
            if audio == .main {
                mainAudioPosition = Self.mainAudioDuration
                customView.progressView.position = mainAudioPosition
                player.stopAdAudio()
            } else {
                instreamAudioAd?.stop()
            }
        default:
            break
        }
    }

    private func playMidroll(at midpoint: TimeInterval) {
        state = .onPause(.main)
        player.pauseAdAudio()

        state = .preparing(.midroll)
        midpoints.removeFirst()
        instreamAudioAd?.player = player
        instreamAudioAd?.startMidroll(withPoint: midpoint as NSNumber)
    }

    private func playPostroll() {
        state = .preparing(.postroll)
        instreamAudioAd?.player = player
        instreamAudioAd?.startPostroll()
    }
}

// MARK: - MTRGInstreamAudioAdDelegate

extension InstreamAudioViewController: MTRGInstreamAudioAdDelegate {
    func onLoad(with instreamAudioAd: MTRGInstreamAudioAd) {
        midpoints = instreamAudioAd.midpoints.map { $0.doubleValue }
        customView.progressView.points = midpoints

        customView.audioParametersInfoView[.timeout] = "\(instreamAudioAd.loadingTimeout)"
        customView.audioParametersInfoView[.volume] = String(format: "%.2f", instreamAudioAd.volume)

        state = .ready
        notificationView.showMessage("onLoad() called")
    }

    func onLoadFailed(error: Error, instreamAudioAd: MTRGInstreamAudioAd) {
        self.instreamAudioAd = nil

        state = .noAd
        notificationView.showMessage("onLoadFailed(\(error)) called")
    }

    func onError(withReason reason: String, instreamAudioAd: MTRGInstreamAudioAd) {
        state = .error(reason: reason)
        notificationView.showMessage("onError(\(reason)) called")
    }

    func onBannerStart(_ banner: MTRGInstreamAudioAdBanner, instreamAudioAd: MTRGInstreamAudioAd) {
        customView.currentAdParametersInfoView[.duration] = String(format: "%.2f", banner.duration)
        customView.currentAdParametersInfoView[.allowSeek] = "\(banner.allowSeek)"
        customView.currentAdParametersInfoView[.allowPause] = "\(banner.allowPause)"
        customView.currentAdParametersInfoView[.allowSkip] = "\(banner.allowSkip)"

        guard case .preparing(let audio) = state else {
            return
        }

        state = .playing(audio)
        customView.ctaButton.setTitle(banner.adText, for: .normal)
        customView.advertisingLabel.text = banner.advertisingLabel
        customView.adChoicesButton.setImage(banner.adChoicesImage, for: .normal)

        if
            let companion = banner.companionBanners.first,
            let resource = companion.staticResource,
            let imageUrl = URL(string: resource) {

                let side = view.bounds.width
                customView.companionImageView.setImage(at: imageUrl,
                                                       size: .init(width: side, height: side),
                                                       completion: { [weak self] isSuccess in
                    if isSuccess {
                        self?.instreamAudioAd?.handleCompanionShow(companion)
                    }
                })
        }

        notificationView.showMessage("onBannerStart() called")
    }

    func onBannerComplete(_ banner: MTRGInstreamAudioAdBanner, instreamAudioAd: MTRGInstreamAudioAd) {
        customView.companionImageView.image = .defaultAudio
        notificationView.showMessage("onBannerComplete() called")
    }

    func onBannerShouldClose(_ banner: MTRGInstreamAudioAdBanner, instreamAudioAd: MTRGInstreamAudioAd) {
        skipBanner()
    }

    func onComplete(withSection section: String, instreamAudioAd: MTRGInstreamAudioAd) {
        notificationView.showMessage("onComplete() called")

        switch state {
        case .preparing(let audio), .playing(let audio), .onPause(let audio):
            switch audio {
            case .postroll:
                state = .complete
            default:
                playMainAudio()
            }
        default:
            break
        }
    }

    func onShowModal(with instreamAudioAd: MTRGInstreamAudioAd) {
        pauseAudio()
        notificationView.showMessage("onShowModal() called")
    }

    func onDismissModal(with instreamAudioAd: MTRGInstreamAudioAd) {
        resumeAudio()
        notificationView.showMessage("onDismissModal() called")
    }

    func onLeaveApplication(with instreamAudioAd: MTRGInstreamAudioAd) {
        notificationView.showMessage("onLeaveApplication() called")
    }
}

// MARK: - MTRGInstreamAudioAdPlayerDelegate

extension InstreamAudioViewController: MTRGInstreamAudioAdPlayerDelegate {

    func onAdAudioStart() {
        guard state == .preparing(.main) else {
            return
        }

        state = .playing(.main)
        startTimer()
    }

    func onAdAudioError(withReason reason: String) {
        state = .error(reason: reason)
        notificationView.showMessage("Error: \(reason)")
    }

    func onAdAudioComplete() {
        completeAudio()
    }

    func onAdAudioPause() { }

    func onAdAudioResume() { }

    func onAdAudioStop() {
        completeAudio()
    }

    private func completeAudio() {
        guard state == .playing(.main) || state == .onPause(.main) else {
            return
        }

        stopTimer()

        if shouldSkipAllAds || instreamAudioAd == nil {
            state = .complete
        } else {
            playPostroll()
        }
    }
}
