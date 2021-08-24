//
//  StandardViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

class StandardViewController: UIViewController, AdViewController, MTRGAdViewDelegate, CollectionViewControllerDelegate
{
	var query: [String : String]?
	
	var slotId: UInt?

	private var adView: MTRGAdView?
	private var adSize: MTRGAdSize?
	private var notificationView: NotificationView?
	private let collectionController = CollectionViewController()

	private let sizeGroup = RadioButtonsGroup()

	@IBOutlet weak var radioButtonAdaptiveAuto: RadioButton!
	@IBOutlet weak var radioButtonAdaptiveManual: RadioButton!
	@IBOutlet weak var radioButton320x50: RadioButton!
	@IBOutlet weak var radioButton300x250: RadioButton!
	@IBOutlet weak var radioButton728x90: RadioButton!

	@IBOutlet weak var showButton: CustomButton!

	override func viewDidLoad()
	{
        super.viewDidLoad()

		navigationItem.title = "Banners"
		notificationView = NotificationView.create(view: view)
		notificationView?.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0

		collectionController.adViewController = self
		collectionController.delegate = self

		radioButtonAdaptiveAuto.isSelected = true
		radioButton728x90.isEnabled = (UIDevice.current.model == "iPad")

		sizeGroup.addButtons([radioButtonAdaptiveAuto, radioButtonAdaptiveManual, radioButton320x50, radioButton300x250, radioButton728x90])
	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		notificationView?.view = view
		adView = nil
	}

	// CollectionViewControllerDelegate
	func orientationChanged()
	{
		guard let adView = adView, radioButtonAdaptiveManual.isSelected else { return }
		adView.adSize = MTRGAdSize.forCurrentOrientation()
	}

	private func defaultSlot(adSize: MTRGAdSize?) -> UInt
	{
		var slot = Slot.standard.bannerAdaptive.rawValue
		guard let adSize = adSize else { return slot }
		switch adSize.type
		{
			case MTRGAdSizeType320x50:
				slot = Slot.standard.banner320x50.rawValue
				break
			case MTRGAdSizeType300x250:
				slot = Slot.standard.banner300x250.rawValue
				break
			case MTRGAdSizeType728x90:
				slot = Slot.standard.banner728x90.rawValue
				break
			default:
				break
		}
		return slot
	}

	@IBAction func show(_ sender: CustomButton)
	{
		refresh()
		notificationView?.view = collectionController.view
		navigationController?.pushViewController(collectionController, animated: true)
	}

	func refresh()
	{
		if radioButton320x50.isSelected
		{
			adSize = MTRGAdSize.adSize320x50()
		}
		else if radioButton300x250.isSelected
		{
			adSize = MTRGAdSize.adSize300x250()
		}
		else if radioButton728x90.isSelected
		{
			adSize = MTRGAdSize.adSize728x90()
		}
		else if radioButtonAdaptiveManual.isSelected
		{
			adSize = MTRGAdSize.forCurrentOrientation()
		}
		else
		{
			adSize = nil
		}

		let slotId = self.slotId ?? defaultSlot(adSize: adSize)
		adView = MTRGAdView(slotId: slotId)
		guard let adView = adView else { return }

		if let adSize = adSize
		{
			adView.adSize = adSize
		}

		adView.frame = CGRect(origin: .zero, size: adView.adSize.size)
		
		collectionController.clean()
		collectionController.adSize = adView.adSize.size
		collectionController.isBottom = adView.adSize.size.height < 100

		prepareAdView(true)
		
		if let query = self.query, query.count > 0
		{
			for item in query
			{
				adView.customParams.setCustomParam(item.value, forKey: item.key)
			}
		}
		
		adView.delegate = self
		adView.load()

		notificationView?.showMessage("Loading...")
	}

	private func prepareAdView(_ isHidden: Bool)
	{
		guard let adView = adView else { return }
		adView.isHidden = isHidden
		adView.removeFromSuperview()
		guard isHidden else { return }
		view.addSubview(adView)
	}

// MARK: - MTRGAdViewDelegate

	func onLoad(with adView: MTRGAdView)
	{
		showButton.isEnabled = true
		notificationView?.showMessage("onLoad() called")

		prepareAdView(false)

		collectionController.adViews = [adView]
		adView.viewController = collectionController
	}

	func onNoAd(withReason reason: String, adView: MTRGAdView)
	{
		notificationView?.showMessage("onNoAd(\(reason)) called")
		prepareAdView(false)
		collectionController.clean()
	}

	func onAdClick(with adView: MTRGAdView)
	{
		notificationView?.showMessage("onAdClick() called")
	}

	func onAdShow(with adView: MTRGAdView)
	{
		notificationView?.showMessage("onAdShow() called")
	}

	func onShowModal(with adView: MTRGAdView)
	{
		notificationView?.showMessage("onShowModal() called")
	}

	func onDismissModal(with adView: MTRGAdView)
	{
		notificationView?.showMessage("onDismissModal() called")
	}

	func onLeaveApplication(with adView: MTRGAdView)
	{
		notificationView?.showMessage("onLeaveApplication() called")
	}
}
