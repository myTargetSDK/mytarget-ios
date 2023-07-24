//
//  InstreamAudioView.swift
//  myTargetDemo
//
//  Created by igor.sorokin on 02.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit

final class InstreamAudioView: UIView {

    enum State: Equatable {
        case notLoaded
        case loading
        case noAd
        case ready
        case preparing(Audio)
        case playing(Audio)
        case onPause(Audio)
        case complete
        case error(reason: String)

        enum Audio: String {
            case main = "Main audio"
            case preroll = "Preroll"
            case midroll = "Midroll"
            case postroll = "Postroll"
        }
    }

    enum AudioParametersInfo: String, CaseIterable {
        case timeout = "Timeout"
        case volume = "Volume"
    }

    enum CurrentAudioAdParametersInfo: String, CaseIterable {
        case duration = "Duration"
        case allowSeek = "Allow seek"
        case allowPause = "Allow pause"
        case allowSkip = "Allow skip"
    }

    private enum PlayerInfo: String, CaseIterable {
        case status = "Status"
    }

    var state: State = .notLoaded {
        didSet {
            applyCurrentState()
        }
    }

    private lazy var scrollView: UIScrollView = .init()
    private lazy var contentView: UIView = .init()

    private(set) lazy var audioParametersInfoView: InfoView<AudioParametersInfo> = .init(title: "Audio parameters",
                                                                                         doubleColumns: true)
    private(set) lazy var currentAdParametersInfoView: InfoView<CurrentAudioAdParametersInfo> = .init(title: "Current ad parameters",
                                                                                                      doubleColumns: true)
    private lazy var playerInfoView: InfoView<PlayerInfo> = .init(title: "Player info")

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    private(set) lazy var adChoicesButton: UIButton = {
        let adChoicesButton = UIButton()
        adChoicesButton.imageView?.contentMode = .scaleAspectFit
        return adChoicesButton
    }()

    private(set) lazy var advertisingLabel: UILabel = {
        let advertisingLabel = UILabel()
        advertisingLabel.textColor = UIColor.foregroundColor()
        return advertisingLabel
    }()

    private(set) lazy var ctaButton: PlayerAdButton = .init(title: "Proceed")
    private(set) lazy var skipButton: PlayerAdButton = .init(title: "Skip")
    private(set) lazy var skipAllButton: PlayerAdButton = .init(title: "Skip All")
    private(set) lazy var progressView = ProgressView(duration: InstreamAudioViewController.mainAudioDuration)
    private(set) lazy var companionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .defaultAudio
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = containerView.bounds
        return imageView
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [playButton, pauseButton, resumeButton, stopButton])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    private(set) lazy var playButton: CustomButton = .init(title: "Play")
    private(set) lazy var pauseButton: CustomButton = .init(title: "Pause")
    private(set) lazy var resumeButton: CustomButton = .init(title: "Resume")
    private(set) lazy var stopButton: CustomButton = .init(title: "Stop")
    private(set) lazy var loadButton: CustomButton = .init(title: "Load")

    private let contentInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    private let playerAdButtonInsets: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    private let infoBottomMargin: CGFloat = 16
    private let playerAdButtonHeight: CGFloat = 32
    private let advertisingLabelHeight: CGFloat = 18
    private let buttonHeight: CGFloat = 40
    private let buttonTopMargin: CGFloat = 8
    private let progressHeight: CGFloat = 6
    private let progressTopMargin: CGFloat = 4

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .backgroundColor()
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(audioParametersInfoView)
        contentView.addSubview(currentAdParametersInfoView)
        contentView.addSubview(playerInfoView)
        contentView.addSubview(containerView)
        contentView.addSubview(progressView)
        contentView.addSubview(buttonsStack)
        contentView.addSubview(loadButton)

        containerView.addSubview(companionImageView)
        containerView.addSubview(ctaButton)
        containerView.addSubview(skipButton)
        containerView.addSubview(skipAllButton)
        containerView.addSubview(adChoicesButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let safeAreaInsets = safeAreaInsets
        let contentWidth = bounds.width - safeAreaInsets.left - safeAreaInsets.right - contentInsets.left - contentInsets.right
        let infoWidth = traitCollection.horizontalSizeClass == .regular ? contentWidth / 2 : contentWidth

        layoutInfoViews(for: infoWidth)
        layoutPlayerInfoView(for: contentWidth)
        layoutContainerView(for: contentWidth)
        layoutProgressView()
        layoutButtons(for: contentWidth)
        layoutContentView(for: contentWidth)
        layoutScrollView()
    }
}

// MARK: - Layout

private extension InstreamAudioView {

    func layoutInfoViews(for contentWidth: CGFloat) {
        let instreamInfoHeight = audioParametersInfoView.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        audioParametersInfoView.frame = CGRect(x: 0,
                                               y: 0,
                                               width: contentWidth,
                                               height: instreamInfoHeight)

        let currentAdInfoHeight = currentAdParametersInfoView.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        let currentAdInfoOrigin: CGPoint
        if traitCollection.horizontalSizeClass == .regular {
            currentAdInfoOrigin = .init(x: audioParametersInfoView.frame.maxX,
                                        y: audioParametersInfoView.frame.origin.y)
        } else {
            currentAdInfoOrigin = .init(x: audioParametersInfoView.frame.origin.x,
                                        y: audioParametersInfoView.frame.maxY + infoBottomMargin)
        }
        currentAdParametersInfoView.frame = CGRect(origin: currentAdInfoOrigin,
                                                   size: .init(width: contentWidth, height: currentAdInfoHeight))
    }

    func layoutPlayerInfoView(for contentWidth: CGFloat) {
        let parametersInfoMaxY: CGFloat
        if traitCollection.horizontalSizeClass == .regular {
            parametersInfoMaxY = max(audioParametersInfoView.frame.maxY, currentAdParametersInfoView.frame.maxY)
        } else {
            parametersInfoMaxY = currentAdParametersInfoView.frame.maxY
        }

        let playerInfoHeight = playerInfoView.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        playerInfoView.frame = CGRect(x: audioParametersInfoView.frame.origin.x,
                                      y: parametersInfoMaxY + infoBottomMargin,
                                      width: contentWidth,
                                      height: playerInfoHeight)
    }

    func layoutContainerView(for contentWidth: CGFloat) {
        let containerHeight = contentWidth
        containerView.frame = CGRect(x: 0,
                                     y: playerInfoView.frame.maxY + infoBottomMargin,
                                     width: contentWidth,
                                     height: containerHeight)

        let ctaButtonWidth = ctaButton.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: playerAdButtonHeight)).width
        ctaButton.frame = CGRect(x: playerAdButtonInsets.left,
                                 y: playerAdButtonInsets.top,
                                 width: ctaButtonWidth,
                                 height: playerAdButtonHeight)

        let skipButtonWidth = skipButton.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: playerAdButtonHeight)).width
        skipButton.frame = CGRect(x: playerAdButtonInsets.left,
                                  y: containerHeight - playerAdButtonInsets.bottom - playerAdButtonHeight,
                                  width: skipButtonWidth,
                                  height: playerAdButtonHeight)

        let skipAllButtonWidth = skipAllButton.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: playerAdButtonHeight)).width
        skipAllButton.frame = CGRect(x: playerInfoView.frame.width - playerAdButtonInsets.right - skipAllButtonWidth,
                                     y: containerHeight - playerAdButtonInsets.bottom - playerAdButtonHeight,
                                     width: skipAllButtonWidth,
                                     height: playerAdButtonHeight)

        let imageSize = adChoicesButton.image(for: .normal)?.size ?? .zero
        let constrainedSize = CGSize(width: playerInfoView.frame.width - ctaButton.frame.maxX - 2 * playerAdButtonInsets.right,
                                     height: playerAdButtonHeight)
        let fitImageSizeWidth = imageSize.resize(targetSize: constrainedSize).width
        adChoicesButton.frame = CGRect(x: playerInfoView.frame.width - playerAdButtonInsets.right - fitImageSizeWidth,
                                       y: playerAdButtonInsets.top,
                                       width: fitImageSizeWidth,
                                       height: playerAdButtonHeight)

        let advertisingLabelWidth = advertisingLabel.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: advertisingLabelHeight)).width
        advertisingLabel.frame = CGRect(x: playerInfoView.frame.width - playerAdButtonInsets.right - advertisingLabelWidth,
                                        y: adChoicesButton.frame.maxY + playerAdButtonInsets.top,
                                        width: advertisingLabelWidth,
                                        height: advertisingLabelHeight)
    }

    func layoutProgressView() {
        progressView.frame = CGRect(x: containerView.frame.origin.x,
                                    y: containerView.frame.maxY + progressTopMargin,
                                    width: containerView.frame.width,
                                    height: progressHeight)
    }

    func layoutButtons(for contentWidth: CGFloat) {
        buttonsStack.frame = CGRect(x: 0,
                                    y: progressView.frame.maxY + buttonTopMargin,
                                    width: contentWidth,
                                    height: buttonHeight)

        loadButton.frame = CGRect(x: 0,
                                  y: buttonsStack.frame.maxY + buttonTopMargin,
                                  width: contentWidth,
                                  height: buttonHeight)
    }

    func layoutContentView(for contentWidth: CGFloat) {
        contentView.frame = CGRect(x: safeAreaInsets.left + contentInsets.left,
                                   y: contentInsets.top,
                                   width: contentWidth,
                                   height: loadButton.frame.maxY + contentInsets.bottom)
    }

    func layoutScrollView() {
        scrollView.frame = bounds
        scrollView.contentSize = .init(width: bounds.width, height: contentView.frame.height)
    }
}

// MARK: - State

private extension InstreamAudioView {

    func applyCurrentState() {
        ctaButton.isHidden = true
        skipButton.isHidden = true
        skipAllButton.isHidden = true
        adChoicesButton.isHidden = true
        advertisingLabel.isHidden = true

        playButton.isEnabled = false
        pauseButton.isEnabled = false
        resumeButton.isEnabled = false
        stopButton.isEnabled = false
        loadButton.isEnabled = true

        switch state {
        case .notLoaded:
            applyNotLoadedState()
        case .loading:
            applyLoadingState()
        case .noAd:
            applyNoAdState()
        case .ready:
            applyReadyState()
        case .preparing(let audio):
            applyPreparingState(audio: audio)
        case .playing(let audio):
            applyPlayingState(audio: audio)
        case .onPause(let audio):
            applyOnPauseState(audio: audio)
        case .complete:
            applyCompleteState()
        case .error(let reason):
            applyErrorState(reason: reason)
        }
    }

    func applyNotLoadedState() {
        playerInfoView[.status] = "Not loaded"
    }

    func applyLoadingState() {
        playerInfoView[.status] = "Loading..."
        loadButton.isEnabled = false

        audioParametersInfoView.clear()
        currentAdParametersInfoView.clear()
    }

    func applyNoAdState() {
        playerInfoView[.status] = "No ad"
        playButton.isEnabled = true
    }

    func applyReadyState() {
        playerInfoView[.status] = "Ready"
        playButton.isEnabled = true
    }

    func applyPreparingState(audio: State.Audio) {
        playerInfoView[.status] = "\(audio.rawValue) loading..."

        switch audio {
        case .main:
            currentAdParametersInfoView.clear()
        case .preroll, .midroll, .postroll:
            [ctaButton, skipButton, skipAllButton, adChoicesButton, advertisingLabel].forEach { containerView.bringSubviewToFront($0) }
        }
    }

    func applyPlayingState(audio: State.Audio) {
        playerInfoView[.status] = audio.rawValue
        pauseButton.isEnabled = true
        stopButton.isEnabled = true

        switch audio {
        case .main:
            break
        case .preroll, .midroll, .postroll:
            ctaButton.isHidden = false
            skipButton.isHidden = false
            skipAllButton.isHidden = false
            adChoicesButton.isHidden = false
            advertisingLabel.isHidden = false
        }
    }

    func applyOnPauseState(audio: State.Audio) {
        playerInfoView[.status] = "\(audio.rawValue) on pause"
        resumeButton.isEnabled = true
        stopButton.isEnabled = true

        switch audio {
        case .main:
            break
        case .preroll, .midroll, .postroll:
            ctaButton.isHidden = false
            skipButton.isHidden = false
            skipAllButton.isHidden = false
            adChoicesButton.isHidden = false
            advertisingLabel.isHidden = false
        }
    }

    func applyCompleteState() {
        playerInfoView[.status] = "Complete"
        currentAdParametersInfoView.clear()
    }

    func applyErrorState(reason: String) {
        playerInfoView[.status] = reason
        playButton.isEnabled = true
    }
}
