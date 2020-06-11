//
//  StandardViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

class StandardViewController: UIViewController, AdViewController, MTRGAdViewDelegate
{
	var slotId: UInt?

	private var adView: MTRGAdView?
	private var adSize = CGSize.zero
	private var notificationView: NotificationView?
	private let collectionController = CollectionViewController()

	private let sizeGroup = RadioButtonsGroup()
	private let typeGroup = RadioButtonsGroup()

	@IBOutlet weak var radioButton320x50: RadioButton!
	@IBOutlet weak var radioButton300x250: RadioButton!
	@IBOutlet weak var radioButton728x90: RadioButton!

	@IBOutlet weak var radioButtonWebview: RadioButton!
	@IBOutlet weak var radioButtonHtml: RadioButton!

	@IBOutlet weak var showButton: CustomButton!

	override func viewDidLoad()
	{
        super.viewDidLoad()

		navigationItem.title = "Banners"
		notificationView = NotificationView.create(view: view)
		notificationView?.navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0.0

		collectionController.adViewController = self

		radioButton320x50.isSelected = true
		radioButtonWebview.isSelected = true
		radioButton728x90.isEnabled = (UIDevice.current.model == "iPad")

		sizeGroup.addButtons([radioButton320x50, radioButton300x250, radioButton728x90])
		typeGroup.addButtons([radioButtonWebview, radioButtonHtml])
	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		notificationView?.view = view
		adView?.viewController = self
	}

	private func defaultSlot(size: MTRGAdSize) -> UInt
	{
		var slot: UInt = 0
		switch size
		{
			case MTRGAdSize_300x250:
				slot = radioButtonHtml.isSelected ? Slot.banner300x250.html.rawValue : Slot.banner300x250.regular.rawValue
				break
			case MTRGAdSize_728x90:
				slot = radioButtonHtml.isSelected ? Slot.banner728x90.html.rawValue : Slot.banner728x90.regular.rawValue
				break
			default:
				slot = radioButtonHtml.isSelected ? Slot.banner320x50.html.rawValue : Slot.banner320x50.regular.rawValue
		}
		return slot
	}

	@IBAction func show(_ sender: CustomButton)
	{
		showButton.isEnabled = false
		refresh()
		notificationView?.view = collectionController.view
		navigationController?.pushViewController(collectionController, animated: true)
	}

	func refresh()
	{
		let size = radioButton300x250.isSelected ? MTRGAdSize_300x250 : radioButton728x90.isSelected ? MTRGAdSize_728x90 : MTRGAdSize_320x50
		switch size
		{
			case MTRGAdSize_300x250:
				adSize = CGSize(width: 300, height: 250)
				break
			case MTRGAdSize_728x90:
				adSize = CGSize(width: 728, height: 90)
				break
			default:
				adSize = CGSize(width: 320, height: 50)
		}
		
		collectionController.adSize = adSize
		collectionController.isBottom = adSize.height < 100

		let slotId = self.slotId ?? defaultSlot(size: size)
		adView = MTRGAdView(slotId: slotId, adSize: size)
		guard let adView = adView else { return }

		prepareAdView(true)

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
		showButton.isEnabled = true
		notificationView?.showMessage("onNoAd(\(reason)) called")
		prepareAdView(false)
		collectionController.adViews = []
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
