//
//  InstreamView.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 24.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

final class InstreamView: UIView {

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

    enum InstreamParametersInfo: String, CaseIterable {
        case fullscreen = "Fullscreen"
        case quality = "Quality"
        case timeout = "Timeout"
        case volume = "Volume"
    }

    enum CurrentAdParametersInfo: String, CaseIterable {
        case duration = "Duration"
        case position = "Position"
        case dimension = "Dimension"
        case allowPause = "Allow pause"
        case allowClose = "Allow close"
        case closeDelay = "Close delay"
    }

    private enum PlayerInfo: String, CaseIterable {
        case status = "Status"
    }

    var state: State = .notLoaded {
        didSet {
            applyCurrentState()
        }
    }
    var adPlayerView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            adPlayerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            adPlayerView?.frame = containerView.bounds
            adPlayerView.map { containerView.addSubview($0) }
        }
    }

    private lazy var scrollView: UIScrollView = .init()
    private lazy var contentView: UIView = .init()

    private(set) lazy var instreamParametersInfoView: InfoView<InstreamParametersInfo> = .init(title: "Instream parameters", doubleColumns: true)
    private(set) lazy var currentAdParametersInfoView: InfoView<CurrentAdParametersInfo> = .init(title: "Current ad parameters", doubleColumns: true)
    private lazy var playerInfoView: InfoView<PlayerInfo> = .init(title: "Player info")

    private(set) lazy var containerView: UIView = .init()
    private(set) lazy var ctaButton: PlayerAdButton = .init(title: "Proceed")
    private(set) lazy var skipButton: PlayerAdButton = .init(title: "Skip")
    private(set) lazy var skipAllButton: PlayerAdButton = .init(title: "Skip All")
    private(set) lazy var progressView = ProgressView(duration: InstreamViewController.mainVideoDuration)
    private(set) lazy var mainVideoView: VideoPlayerView = {
        let mainVideoView = VideoPlayerView()
        mainVideoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainVideoView.frame = containerView.bounds
        return mainVideoView
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
    private let containerHeight: CGFloat = 200
    private let playerAdButtonHeight: CGFloat = 32
    private let advertisingLabelHeight: CGFloat = 18
    private let progressTopMargin: CGFloat = 2
    private let progressHeight: CGFloat = 6
    private let buttonTopMargin: CGFloat = 8
    private let buttonHeight: CGFloat = 40

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

        contentView.addSubview(instreamParametersInfoView)
        contentView.addSubview(currentAdParametersInfoView)
        contentView.addSubview(playerInfoView)
        contentView.addSubview(containerView)
        contentView.addSubview(progressView)
        contentView.addSubview(buttonsStack)
        contentView.addSubview(loadButton)

        containerView.addSubview(ctaButton)
        containerView.addSubview(skipButton)
        containerView.addSubview(skipAllButton)
        containerView.addSubview(mainVideoView)
        containerView.addSubview(adChoicesButton)
        containerView.addSubview(advertisingLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let safeAreaInsets = safeAreaInsets
        let contentWidth = bounds.width - safeAreaInsets.left - safeAreaInsets.right - contentInsets.left - contentInsets.right
        let infoWidth = traitCollection.horizontalSizeClass == .regular ? contentWidth / 2 : contentWidth

        layoutInfoViews(for: infoWidth)
        layoutPlayerView(for: contentWidth)
        layoutContainerView(for: contentWidth)
        layoutProgressView()
        layoutButtons(for: contentWidth)
        layoutContentView(for: contentWidth)
        layoutScrollView()
    }

}

// MARK: - Layout

private extension InstreamView {

    func layoutInfoViews(for contentWidth: CGFloat) {
        let instreamInfoHeight = instreamParametersInfoView.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        instreamParametersInfoView.frame = CGRect(x: 0,
                                                  y: 0,
                                                  width: contentWidth,
                                                  height: instreamInfoHeight)

        let currentAdInfoHeight = currentAdParametersInfoView.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        let currentAdInfoOrigin: CGPoint
        if traitCollection.horizontalSizeClass == .regular {
            currentAdInfoOrigin = .init(x: instreamParametersInfoView.frame.maxX,
                                        y: instreamParametersInfoView.frame.origin.y)
        } else {
            currentAdInfoOrigin = .init(x: instreamParametersInfoView.frame.origin.x,
                                        y: instreamParametersInfoView.frame.maxY + infoBottomMargin)
        }
        currentAdParametersInfoView.frame = CGRect(origin: currentAdInfoOrigin,
                                                   size: .init(width: contentWidth, height: currentAdInfoHeight))
    }

    func layoutPlayerView(for contentWidth: CGFloat) {
        let parametersInfoMaxY: CGFloat
        if traitCollection.horizontalSizeClass == .regular {
            parametersInfoMaxY = max(instreamParametersInfoView.frame.maxY, currentAdParametersInfoView.frame.maxY)
        } else {
            parametersInfoMaxY = currentAdParametersInfoView.frame.maxY
        }

        let playerInfoHeight = playerInfoView.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        playerInfoView.frame = CGRect(x: instreamParametersInfoView.frame.origin.x,
                                      y: parametersInfoMaxY + infoBottomMargin,
                                      width: contentWidth,
                                      height: playerInfoHeight)
    }

    func layoutContainerView(for contentWidth: CGFloat) {
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
        let adChoicesButtonWidth = adChoicesButtonSize(imageSize: imageSize, constrainedSize: constrainedSize).width
        adChoicesButton.frame = CGRect(x: playerInfoView.frame.width - playerAdButtonInsets.right - adChoicesButtonWidth,
                                       y: playerAdButtonInsets.top,
                                       width: adChoicesButtonWidth,
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
        scrollView.contentSize = .init(width: bounds.width,
                                       height: contentView.frame.height)
    }

    func adChoicesButtonSize(imageSize: CGSize, constrainedSize: CGSize) -> CGSize {
        guard imageSize.width != 0, imageSize.height != 0 else {
            return .zero
        }

        let ratio = imageSize.width / imageSize.height
        let ratioWidth = constrainedSize.height * ratio
        let width = min(ratioWidth, constrainedSize.width)
        return CGSize(width: width, height: constrainedSize.height)
    }

}

// MARK: - State

private extension InstreamView {

    func applyCurrentState() {
        mainVideoView.isHidden = true
        adPlayerView?.isHidden = true
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
        case .preparing(let video):
            applyPreparingState(video: video)
        case .playing(let video):
            applyPlayingState(video: video)
        case .onPause(let video):
            applyOnPauseState(video: video)
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

        instreamParametersInfoView.clear()
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

    func applyPreparingState(video: State.Video) {
        playerInfoView[.status] = "\(video.rawValue) loading..."

        switch video {
        case .main:
            mainVideoView.isHidden = false
            containerView.bringSubviewToFront(mainVideoView)
            currentAdParametersInfoView.clear()
        case .preroll, .midroll, .postroll:
            adPlayerView.map {
                containerView.bringSubviewToFront($0)
                $0.isHidden = false
            }
            [ctaButton, skipButton, skipAllButton, adChoicesButton, advertisingLabel].forEach { containerView.bringSubviewToFront($0) }
        }
    }

    func applyPlayingState(video: State.Video) {
        playerInfoView[.status] = video.rawValue
        pauseButton.isEnabled = true
        stopButton.isEnabled = true

        switch video {
        case .main:
            mainVideoView.isHidden = false
        case .preroll, .midroll, .postroll:
            adPlayerView?.isHidden = false
            ctaButton.isHidden = false
            skipButton.isHidden = false
            skipAllButton.isHidden = false
            adChoicesButton.isHidden = false
            advertisingLabel.isHidden = false
        }
    }

    func applyOnPauseState(video: State.Video) {
        playerInfoView[.status] = "\(video.rawValue) on pause"
        resumeButton.isEnabled = true
        stopButton.isEnabled = true

        switch video {
        case .main:
            mainVideoView.isHidden = false
        case .preroll, .midroll, .postroll:
            adPlayerView?.isHidden = false
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
