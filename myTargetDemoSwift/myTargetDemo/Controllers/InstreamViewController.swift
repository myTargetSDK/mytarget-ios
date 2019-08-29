//
//  InstreamViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 06/08/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

class InstreamViewController: UIViewController, MTRGInstreamAdDelegate, VideoPlayerViewDelegate
{
	var slotId: UInt?

	private var instreamAd: MTRGInstreamAd?
	private var notificationView: NotificationView?

	private static let mainVideoUrl = "https://r.mradx.net/img/8D/548043.mp4"
	private static let mainVideoDuration = 25.612

	private let adContainerView = UIView()
	private let mainVideoView = VideoPlayerView()
	private let videoProgressView = VideoProgressView(duration: InstreamViewController.mainVideoDuration)

	private let ctaButton = UIButton()
	private let skipButton = UIButton()
	private let skipAllButton = UIButton()

	private var mainVideoDuration: TimeInterval = InstreamViewController.mainVideoDuration
	private var mainVideoPosition: TimeInterval = 0

	private var activeMidpoints = [Float]()
	private var customMidPoints = [NSNumber]()
	private var customMidPointsP = [NSNumber]()
	private var midpoints = [NSNumber]()

	private var skipAll = false
	private var isModalActive = false
	private var isMainVideoActive = false
	private var isMainVideoStarted = false
	private var isMainVideoFinished = false
	private var isPrerollActive = false
	private var isMidrollActive = false
	private var isPauserollActive = false
	private var isPostrollActive = false
	private var isAdActive: Bool
	{
		return isPrerollActive || isPrerollActive || isPauserollActive || isPostrollActive
	}

	private var timer: Timer?

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var contentView: UIView!

	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var progressView: UIView!
	
	@IBOutlet weak var fullscreenLabel: UILabel!
	@IBOutlet weak var qualityLabel: UILabel!
	@IBOutlet weak var timeoutLabel: UILabel!
	@IBOutlet weak var volumeLabel: UILabel!

	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var positionLabel: UILabel!
	@IBOutlet weak var dimensionsLabel: UILabel!
	@IBOutlet weak var allowPauseLabel: UILabel!
	@IBOutlet weak var allowCloseLabel: UILabel!
	@IBOutlet weak var closeDelayLabel: UILabel!

	@IBOutlet weak var playButton: CustomButton!
	@IBOutlet weak var pauseButton: CustomButton!
	@IBOutlet weak var resumeButton: CustomButton!
	@IBOutlet weak var stopButton: CustomButton!
	@IBOutlet weak var loadButton: CustomButton!

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setupObservers()
	}

	required init?(coder: NSCoder)
	{
		super.init(coder: coder)
		setupObservers()
	}

	private func setupObservers()
	{
		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	deinit
	{
		NotificationCenter.default.removeObserver(self)
	}

	@objc private func applicationWillResignActive(notification: Notification)
	{
		doPause()
	}

	@objc private func applicationDidBecomeActive(notification: Notification)
	{
		doResume()
	}

    override func viewDidLoad()
	{
        super.viewDidLoad()

		navigationItem.title = "Instream"
		notificationView = NotificationView.create(view: view)
		notificationView?.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0

		mainVideoView.isHidden = true
		mainVideoView.delegate = self
		mainVideoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		mainVideoView.frame = containerView.bounds
		containerView.addSubview(mainVideoView)

		ctaButton.isHidden = true
		skipButton.isHidden = true
		skipAllButton.isHidden = true

		ctaButton.addTarget(self, action: #selector(ctaButtonClick), for: .touchUpInside)
		ctaButton.translatesAutoresizingMaskIntoConstraints = false
		configureButton(ctaButton, title: "Proceed")
		containerView.addSubview(ctaButton)

		skipButton.addTarget(self, action: #selector(skipButtonClick), for: .touchUpInside)
		skipButton.translatesAutoresizingMaskIntoConstraints = false
		configureButton(skipButton, title: "Skip")
		containerView.addSubview(skipButton)

		skipAllButton.addTarget(self, action: #selector(skipAllButtonClick), for: .touchUpInside)
		skipAllButton.translatesAutoresizingMaskIntoConstraints = false
		configureButton(skipAllButton, title: "Skip All")
		containerView.addSubview(skipAllButton)

		videoProgressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		videoProgressView.frame = progressView.bounds
		progressView.addSubview(videoProgressView)
    }

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		notificationView?.view = view

		var contentSize = scrollView.contentSize
		contentSize.height = contentView.frame.height
		scrollView.contentSize = contentSize
	}

	override func viewWillDisappear(_ animated: Bool)
	{
		super.viewWillDisappear(animated)
		guard !isModalActive else { return }
		doStop()
	}

	@IBAction func load(_ sender: CustomButton)
	{
		doLoad()
	}

	@IBAction func play(_ sender: CustomButton)
	{
		doPlay()
	}

	@IBAction func pause(_ sender: CustomButton)
	{
		doPause()
	}

	@IBAction func resume(_ sender: CustomButton)
	{
		doResume()
	}

	@IBAction func stop(_ sender: CustomButton)
	{
		doStop()
	}

// MARK: - private

	private func configureMidrolls()
	{
		guard let instreamAd = instreamAd else { return }

		if !customMidPoints.isEmpty
		{
			instreamAd.configureMidpoints(customMidPoints, forVideoDuration: InstreamViewController.mainVideoDuration)
		}
		else if !customMidPointsP.isEmpty
		{
			instreamAd.configureMidpointsP(customMidPoints, forVideoDuration: InstreamViewController.mainVideoDuration)
		}
		else
		{
			instreamAd.configureMidpoints(forVideoDuration: InstreamViewController.mainVideoDuration)
		}
	}

	private func setupButtons()
	{
		guard let adPlayerView = instreamAd?.player?.adPlayerView else { return }

		let width: CGFloat = 75.0
		let height: CGFloat = 30.0
		let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

		ctaButton.removeFromSuperview()
		skipButton.removeFromSuperview()
		skipAllButton.removeFromSuperview()

		adPlayerView.addSubview(ctaButton)
		adPlayerView.addSubview(skipButton)
		adPlayerView.addSubview(skipAllButton)

		let views: [String : Any] = ["ctaButton" : ctaButton, "skipButton" : skipButton, "skipAllButton" : skipAllButton]
		let metrics: [String : Any] = ["top" : insets.top, "bottom" : insets.bottom, "left" : insets.left, "right" : insets.right, "width" : width, "height" : height]
		adPlayerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[ctaButton]-(>=right)-|", options: [], metrics: metrics, views: views))
		adPlayerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[ctaButton(height)]", options: [], metrics: metrics, views: views))
		adPlayerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[skipButton(width)]", options: [], metrics: metrics, views: views))
		adPlayerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[skipButton(height)]-bottom-|", options: [], metrics: metrics, views: views))
		adPlayerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[skipAllButton(width)]-right-|", options: [], metrics: metrics, views: views))
		adPlayerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[skipAllButton(height)]-bottom-|", options: [], metrics: metrics, views: views))
	}

	private func configureButton(_ button: UIButton, title: String)
	{
		button.setTitle(title, for: .normal)
		button.setTitleColor(UIColor.foregroundColor(), for: .normal)
		button.setTitleColor(UIColor.disabledColor(), for: .disabled)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
		button.titleLabel?.lineBreakMode = .byTruncatingTail
		button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
		button.backgroundColor = UIColor.backgroundColor().withAlphaComponent(0.3)
		button.layer.borderColor = UIColor.foregroundColor().cgColor
		button.layer.borderWidth = 1
		button.layer.cornerRadius = 5
	}

// MARK: - actions

	private func doLoad()
	{
		if isMainVideoStarted
		{
			mainVideoView.stop()
			videoProgressView.position = 0
		}

		if let instreamAd = instreamAd
		{
			instreamAd.stop()
			instreamAd.player?.adPlayerView.removeFromSuperview()
			self.instreamAd = nil
		}

		let slotId = self.slotId ?? Slot.instreamVideo.rawValue
		instreamAd = MTRGInstreamAd(slotId: slotId)
		guard let instreamAd = instreamAd else { return }
		instreamAd.useDefaultPlayer()
		instreamAd.delegate = self

		mainVideoPosition = 0

		isMainVideoStarted = false
		isMainVideoActive = false
		isMainVideoFinished = false
		isModalActive = false

		isPrerollActive = false
		isMidrollActive = false
		isPostrollActive = false
		isPauserollActive = false

		skipAll = false

		ctaButton.removeFromSuperview()
		skipButton.removeFromSuperview()
		skipAllButton.removeFromSuperview()

		statusLabel.text = "Loading..."
		loadButton.isEnabled = false

		configureMidrolls()
		instreamAd.customParams.age = 100
		instreamAd.customParams.gender = MTRGGenderUnknown

		instreamAd.load()
	}

	private func doPlay()
	{
		if isMainVideoStarted && isMainVideoActive
		{
			playMainVideo()
		}
		else
		{
			playPreroll()
		}
	}

	private func doPause()
	{
		if isMainVideoStarted && isMainVideoActive
		{
			playPauseroll()
		}
		else if isAdActive, let instreamAd = instreamAd
		{
			instreamAd.pause()
		}
	}

	private func doResume()
	{
		if isMainVideoStarted && isMainVideoActive
		{
			mainVideoView.resume()
		}
		else if isAdActive, let instreamAd = instreamAd
		{
			instreamAd.resume()
		}
	}

	private func doStop()
	{
		if isMainVideoStarted && isMainVideoActive
		{
			mainVideoView.stop()
			videoProgressView.position = 0
		}
		else if isAdActive, let instreamAd = instreamAd
		{
			instreamAd.stop()
		}
		timerStop()
	}

	private func doFullscreen(isFullscreen: Bool)
	{
		guard let instreamAd = instreamAd else { return }
		instreamAd.fullscreen = isFullscreen
	}

	private func doSkip()
	{
		guard isAdActive, let instreamAd = instreamAd else { return }
		instreamAd.skipBanner()
	}

	private func doSkipAll()
	{
		guard isAdActive, let instreamAd = instreamAd else { return }
		activeMidpoints.removeAll()
		skipAll = true
		instreamAd.skip()
	}

	private func doBannerClick()
	{
		guard isAdActive, let instreamAd = instreamAd else { return }
		instreamAd.handleClick(with: self)
	}

// MARK: - video

	private func playMainVideo()
	{
		guard let url = URL(string: InstreamViewController.mainVideoUrl) else { return }
		setVisibility(mainPlayerVisible: true, adPlayerVisible: false)
		statusLabel.text = "Main video"
		isMainVideoActive = true
		mainVideoView.isHidden = false
		mainVideoView.start(with: url, position: mainVideoPosition)
	}

	private func playPreroll()
	{
		guard let instreamAd = instreamAd else { return }
		isPrerollActive = true
		statusLabel.text = "Preroll"
		setVisibility(mainPlayerVisible: false, adPlayerVisible: true)
		instreamAd.startPreroll()
	}

	private func playPauseroll()
	{
		guard let instreamAd = instreamAd else { return }
		mainVideoPosition = mainVideoView.currentTime
		mainVideoView.pause()
		setVisibility(mainPlayerVisible: false, adPlayerVisible: true)
		isPauserollActive = true
		isMainVideoActive = false
		statusLabel.text = "Pauseroll"
		instreamAd.startPauseroll()
	}

	private func playMidroll(_ midpoint: Float)
	{
		guard let instreamAd = instreamAd else { return }
		mainVideoPosition = mainVideoView.currentTime
		mainVideoView.pause()
		setVisibility(mainPlayerVisible: false, adPlayerVisible: true)
		isMidrollActive = true
		isMainVideoActive = false
		statusLabel.text = "Midroll"
		instreamAd.startMidroll(withPoint: NSNumber(value: midpoint))
	}

	private func playPostroll()
	{
		guard let instreamAd = instreamAd else { return }
		isPostrollActive = true
		statusLabel.text = "Postroll"
		setVisibility(mainPlayerVisible: false, adPlayerVisible: true)
		instreamAd.startPostroll()
	}

	private func setVisibility(mainPlayerVisible: Bool, adPlayerVisible: Bool)
	{
		mainVideoView.isHidden = !mainPlayerVisible
		ctaButton.isHidden = !adPlayerVisible
		skipButton.isHidden = !adPlayerVisible
		skipAllButton.isHidden = !adPlayerVisible
		videoProgressView.isHidden = !mainPlayerVisible && !adPlayerVisible

		guard let instreamAd = instreamAd, let player = instreamAd.player else { return }
		player.adPlayerView.isHidden = !adPlayerVisible
	}

// MARK: - main video

	private func midpoint(for position: TimeInterval) -> Float?
	{
		guard !activeMidpoints.isEmpty, let midpoint = activeMidpoints.first else { return nil }
		guard position >= Double(midpoint) else { return nil }
		activeMidpoints.removeFirst()
		return midpoint
	}

	private func updateStateByTimer()
	{
		guard isMainVideoActive else { return }
		let currentTime = mainVideoView.currentTime

		if currentTime > InstreamViewController.mainVideoDuration
		{
			timerStop()
			mainVideoView.stop()
			return
		}
		videoProgressView.position = currentTime

		if let midpoint = midpoint(for: currentTime)
		{
			playMidroll(midpoint)
			timerStop()
		}
		else
		{
			timerStart()
		}
	}

// MARK: - timer

	private func timerStart()
	{
		timerStop()
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFire), userInfo: nil, repeats: false)
	}

	private func timerStop()
	{
		guard let timer = timer else { return }
		if timer.isValid
		{
			timer.invalidate()
		}
		self.timer = nil
	}

	@objc private func timerFire()
	{
		timerStop()
		updateStateByTimer()
	}

// MARK: - buttons

	@objc private func ctaButtonClick()
	{
		doBannerClick()
	}

	@objc private func skipButtonClick()
	{
		doSkip()
	}

	@objc private func skipAllButtonClick()
	{
		doSkipAll()
	}

// MARK: - VideoPlayerViewDelegate

	func onVideoStarted(url: URL)
	{
		guard isMainVideoActive else { return }
		isMainVideoStarted = true
		mainVideoDuration = mainVideoView.duration
		timerStart()
	}

	func onVideoComplete()
	{
		guard isMainVideoActive else { return }

		timerStop()
		isMainVideoActive = false

		if skipAll
		{
			statusLabel.text = "Complete"
			setVisibility(mainPlayerVisible: false, adPlayerVisible: false)
		}
		else
		{
			playPostroll()
		}
	}

	func onVideoFinished(error: String)
	{
		notificationView?.showMessage("Error: \(error)")
		isMainVideoActive = false
	}

// MARK: - MTRGInstreamAdDelegate

	func onLoad(with instreamAd: MTRGInstreamAd)
	{
		loadButton.isEnabled = true
		notificationView?.showMessage("onLoad() called")
		statusLabel.text = "Ready"

		midpoints = instreamAd.midpoints
		activeMidpoints.removeAll()
		if !midpoints.isEmpty
		{
			activeMidpoints.append(contentsOf: midpoints.map({ return $0.floatValue }))
		}

		videoProgressView.points = activeMidpoints

		qualityLabel.text = "\(instreamAd.videoQuality)"
		timeoutLabel.text = "\(instreamAd.loadingTimeout)"
		volumeLabel.text = String(format: "%.2f", instreamAd.volume)
		fullscreenLabel.text = instreamAd.fullscreen ? "true" : "false"

		guard let adPlayerView = instreamAd.player?.adPlayerView else { return }
		adPlayerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		adPlayerView.frame = containerView.bounds
		containerView.addSubview(adPlayerView)
	}

	func onNoAd(withReason reason: String, instreamAd: MTRGInstreamAd)
	{
		loadButton.isEnabled = true
		notificationView?.showMessage("onNoAd(\(reason)) called")
		statusLabel.text = "No ad"
		self.instreamAd = nil
		playMainVideo()
	}

	func onError(withReason reason: String, instreamAd: MTRGInstreamAd)
	{
		notificationView?.showMessage("onError(\(reason)) called")
		statusLabel.text = "Error: \(reason)"
		playMainVideo()
	}

	func onBannerStart(_ banner: MTRGInstreamAdBanner, instreamAd: MTRGInstreamAd)
	{
		notificationView?.showMessage("onBannerStart() called")
		ctaButton.setTitle(banner.ctaText, for: .normal)
		setupButtons()

		durationLabel.text = String(format: "%.2f", banner.duration)
		positionLabel.text = "0"
		dimensionsLabel.text = String(format: "%.fx%.f", banner.size.width, banner.size.height)
		allowPauseLabel.text = banner.allowPause ? "true" : "false"
		allowCloseLabel.text = banner.allowClose ? "true" : "false"
		closeDelayLabel.text = String(format: "%.2f", banner.allowCloseDelay)
	}

	func onBannerComplete(_ banner: MTRGInstreamAdBanner, instreamAd: MTRGInstreamAd)
	{
		notificationView?.showMessage("onBannerComplete() called")
	}

	func onBannerTimeLeftChange(_ timeLeft: TimeInterval, duration: TimeInterval, instreamAd: MTRGInstreamAd)
	{
		positionLabel.text = String(format: "%.2f", duration - timeLeft)
		print("onBannerTimeLeftChange(" + String(format: "timeLeft: %.2f", timeLeft) + ", " + String(format: "duration: %.2f", duration) + ") called")
	}

	func onComplete(withSection section: String, instreamAd: MTRGInstreamAd)
	{
		notificationView?.showMessage("onComplete() called")

		durationLabel.text = "n/a"
		positionLabel.text = "n/a"
		dimensionsLabel.text = "n/a"
		allowPauseLabel.text = "n/a"
		allowCloseLabel.text = "n/a"
		closeDelayLabel.text = "n/a"

		if isPrerollActive
		{
			isPrerollActive = false
			playMainVideo()
		}

		if isMidrollActive
		{
			isMidrollActive = false
			timerStart()
			playMainVideo()
		}

		if isPauserollActive
		{
			isPauserollActive = false
			timerStart()
			playMainVideo()
		}

		if isPostrollActive
		{
			isPostrollActive = false
			notificationView?.showMessage("Complete")
			setVisibility(mainPlayerVisible: false, adPlayerVisible: false)
		}
	}

	func onShowModal(with instreamAd: MTRGInstreamAd)
	{
		isModalActive = true
		doPause()
		notificationView?.showMessage("onShowModal() called")
	}

	func onDismissModal(with instreamAd: MTRGInstreamAd)
	{
		isModalActive = false
		doResume()
		notificationView?.showMessage("onDismissModal() called")
	}

	func onLeaveApplication(with instreamAd: MTRGInstreamAd)
	{
		notificationView?.showMessage("onLeaveApplication() called")
	}
}
