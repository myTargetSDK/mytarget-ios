//
//  UnitViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 30/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

class UnitViewController: UIViewController, UITextFieldDelegate
{
	private let typeGroup = RadioButtonsGroup()
	private let customAdvertismentsKey = "customAdvertismentsKey"

	private let buttonSize = CGSize(width: 50, height: 28)
	private let buttonMargins = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)

	@IBOutlet weak var slotIdTextField: UITextField!
	@IBOutlet weak var slotTitleTextField: UITextField!

	@IBOutlet weak var radioButtonNative: RadioButton!
	@IBOutlet weak var radioButtonInterstitial: RadioButton!
	@IBOutlet weak var radioButtonRewarded: RadioButton!
	@IBOutlet weak var radioButtonInstream: RadioButton!
	@IBOutlet weak var radioButtonBanner320x50: RadioButton!
	@IBOutlet weak var radioButtonBanner300x250: RadioButton!
	@IBOutlet weak var radioButtonBanner728x90: RadioButton!

	override func viewDidLoad()
	{
        super.viewDidLoad()

		navigationItem.title = "Add custom slot"
		radioButtonBanner320x50.isSelected = true
		radioButtonBanner728x90.isEnabled = (UIDevice.current.model == "iPad")

		radioButtonNative.adType = .native
		radioButtonNative.adDescription = "Native"

		radioButtonInterstitial.adType = .interstitial
		radioButtonInterstitial.adDescription = "Interstitial"

		radioButtonRewarded.adType = .interstitial
		radioButtonRewarded.adDescription = "Rewarded"

		radioButtonInstream.adType = .instream
		radioButtonInstream.adDescription = "Instream"

		radioButtonBanner320x50.adType = .standard
		radioButtonBanner320x50.adDescription = "Banner 320x50"

		radioButtonBanner300x250.adType = .standard
		radioButtonBanner300x250.adDescription = "Banner 300x250"

		radioButtonBanner728x90.adType = .standard
		radioButtonBanner728x90.adDescription = "Banner 728x90"

		typeGroup.addButtons([radioButtonNative, radioButtonInterstitial, radioButtonRewarded, radioButtonInstream, radioButtonBanner320x50, radioButtonBanner300x250, radioButtonBanner728x90])


		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneButtonClick))
		view.addGestureRecognizer(tapRecognizer)

//		let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonClick))
//		let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//		let toolbar = UIToolbar()
//		toolbar.items = [flexibleSpace, doneButton]
//		toolbar.sizeToFit()
//		slotIdTextField.inputAccessoryView = toolbar

		let buttonFrame = CGRect(x: buttonMargins.left, y: buttonMargins.top, width: buttonSize.width, height: buttonSize.height)
		let doneButton = CustomButton(frame: buttonFrame)
		doneButton.setTitle("Done", for: .normal)
		doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)

		let toolbarWidth = buttonSize.width + (buttonMargins.left + buttonMargins.right)
		let toolbarHeight = buttonSize.height + (buttonMargins.top + buttonMargins.bottom)
		let toolbarSize = CGSize(width: toolbarWidth, height: toolbarHeight)
		let toolbar = UIView(frame: CGRect(origin: .zero, size: toolbarSize))
		toolbar.addSubview(doneButton)
		slotIdTextField.inputAccessoryView = toolbar

		slotTitleTextField.delegate = self
    }

	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		slotIdTextField.becomeFirstResponder()
	}

	@objc private func doneButtonClick()
	{
		view.endEditing(true)
	}

	@IBAction func add(_ sender: CustomButton)
	{
		guard let slot = slotIdTextField.text, let slotId = UInt(slot), slotId > 0 else { return }
		guard let title = slotTitleTextField.text, !title.isEmpty else { return }
		guard let selectedButton = typeGroup.selectedButton else { return }

		let type = selectedButton.adType
		let description = selectedButton.adDescription + ", Slot: \(slotId)"
		let advertisment = Advertisment(title: title, description: description, type: type, slotId: slotId, isCustom: true)

		let userDefaults = UserDefaults.standard
		var customAdvertisments = userDefaults.array(forKey: customAdvertismentsKey) as? [[String:Any]] ?? [[String:Any]]()
		customAdvertisments.append(advertisment.toDictionary())
		userDefaults.set(customAdvertisments, forKey: customAdvertismentsKey)
		userDefaults.synchronize()

		navigationController?.popViewController(animated: true)
	}

// MARK: - UITextFieldDelegate

	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		textField.resignFirstResponder()
		return true
	}
}
