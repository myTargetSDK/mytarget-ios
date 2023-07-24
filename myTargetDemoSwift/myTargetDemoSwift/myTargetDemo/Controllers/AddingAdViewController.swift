//
//  AddingAdViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 23.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

protocol AddingAdViewControllerDelegate: AnyObject {
    func addingAdViewControllerDidAddCustomAdvertisment(_ customAdvertisment: CustomAdvertisment)
}

final class AddingAdViewController: UIViewController {

    private enum RadioButtons: String, CaseIterable {
        case banner = "Banner"
        case interstitial = "Interstitial"
        case rewarded = "Rewarded"
        case native = "Native"
        case nativeBanner = "Native banner"
        case instream = "Instream"
    }

    weak var delegate: AddingAdViewControllerDelegate?

    private lazy var notificationView: NotificationView = .create(view: view)
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    private lazy var contentView: UIView = .init()
    private lazy var slotInputView: InputView = {
        let inputView = InputView(title: "Slot id")
        inputView.textField.accessibilityLabel = "Slot id"
        inputView.textField.keyboardType = .numberPad
        inputView.textField.delegate = self
        return inputView
    }()
    private lazy var titleInputView: InputView = {
        let inputView = InputView(title: "Title")
        inputView.textField.accessibilityLabel = "Unit title"
        inputView.textField.text = "Custom"
        inputView.textField.returnKeyType = .done
        inputView.textField.delegate = self
        return inputView
    }()
    private lazy var paramsInputView: InputView = {
        let inputView = InputView(title: "Params")
        inputView.textField.accessibilityIdentifier = "query"
        inputView.textField.placeholder = "key0=val0&key1=val1"
        inputView.textField.returnKeyType = .done
        inputView.textField.delegate = self
        return inputView
    }()
    private lazy var radioButtons: RadioButtonsView<RadioButtons> = .init(title: "Ad type")
    private lazy var addButton: CustomButton = .init(title: "Add")

    private var isFirstAppear: Bool = true

    private let contentInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 16, right: 16)
    private let inputViewBottomMargin: CGFloat = 8
    private let radioButtonsTopMargin: CGFloat = 8
    private let buttonTopMargin: CGFloat = 16
    private let buttonHeight: CGFloat = 40

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Adding ad"

        view.backgroundColor = .backgroundColor()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(slotInputView)
        contentView.addSubview(titleInputView)
        contentView.addSubview(paramsInputView)
        contentView.addSubview(radioButtons)
        contentView.addSubview(addButton)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap(_:)))
        view.addGestureRecognizer(tapRecognizer)

        let toolbar = UIToolbar()
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBarButtonTap(_:)))
        toolbar.setItems([spacer, doneBarButton], animated: false)
        toolbar.sizeToFit()
        slotInputView.textField.inputAccessoryView = toolbar

        addButton.addTarget(self, action: #selector(addButtonTap(_:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInsets = view.safeAreaInsets
        let contentWidth = view.bounds.width - safeAreaInsets.left - safeAreaInsets.right - contentInsets.left - contentInsets.right

        let slotInputViewSize = slotInputView.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude))
        slotInputView.frame = CGRect(origin: .zero, size: slotInputViewSize)

        let titleInputViewSize = titleInputView.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude))
        titleInputView.frame = CGRect(x: slotInputView.frame.origin.x,
                                      y: slotInputView.frame.maxY + inputViewBottomMargin,
                                      width: titleInputViewSize.width,
                                      height: titleInputViewSize.height)

        let paramsInputViewSize = paramsInputView.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude))
        paramsInputView.frame = CGRect(x: titleInputView.frame.origin.x,
                                       y: titleInputView.frame.maxY + inputViewBottomMargin,
                                       width: paramsInputViewSize.width,
                                       height: paramsInputViewSize.height)

        let radioButtonsHeight = radioButtons.sizeThatFits(.init(width: contentWidth, height: .greatestFiniteMagnitude)).height
        radioButtons.frame = CGRect(x: 0,
                                    y: paramsInputView.frame.maxY + inputViewBottomMargin + radioButtonsTopMargin,
                                    width: contentWidth,
                                    height: radioButtonsHeight)

        addButton.frame = CGRect(x: 0,
                                 y: radioButtons.frame.maxY + buttonTopMargin,
                                 width: contentWidth,
                                 height: buttonHeight)

        contentView.frame = CGRect(x: safeAreaInsets.left + contentInsets.left,
                                   y: contentInsets.top,
                                   width: contentWidth,
                                   height: addButton.frame.maxY + contentInsets.bottom)
        scrollView.frame = view.bounds
        scrollView.contentSize = .init(width: view.bounds.width, height: contentView.frame.height)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isFirstAppear {
            slotInputView.textField.becomeFirstResponder()
            isFirstAppear = false
        }
    }

    // MARK: - Private

    private func endEditing() {
        view.endEditing(true)
    }

    private func addCustomAdvertisment() {
        guard let slotText = slotInputView.textField.text, let slotId = UInt(slotText), slotId > 0 else {
            notificationView.showMessage("Invalid slot id")
            return
        }

        guard let title = titleInputView.textField.text, !title.isEmpty else {
            notificationView.showMessage("Invalid title")
            return
        }

        let advertismentType: AdvertismentType
        switch radioButtons.selectedRadioButtonType {
        case .banner:
            advertismentType = .banner
        case .interstitial:
            advertismentType = .interstitial
        case .rewarded:
            advertismentType = .rewarded
        case .native:
            advertismentType = .native
        case .nativeBanner:
            advertismentType = .nativeBanner
        case .instream:
            advertismentType = .instream
        }

        let description = radioButtons.selectedRadioButtonType.rawValue + ", Slot: \(slotId)"

        var query: [String: String]?
        if let params = paramsInputView.textField.text, !params.isEmpty {
            query = params
                .components(separatedBy: "&")
                .map { $0.components(separatedBy: "=") }
                .reduce(into: [String: String]()) { $1.count == 2 ? $0[$1[0]] = $1[1] : () }
        }

        let customAdvertisment = CustomAdvertisment(title: title,
                                                    description: description,
                                                    type: advertismentType,
                                                    slotId: slotId,
                                                    query: query)
        delegate?.addingAdViewControllerDidAddCustomAdvertisment(customAdvertisment)
    }

    // MARK: - Actions

    @objc private func viewTap(_ sender: UITapGestureRecognizer) {
        endEditing()
    }

    @objc private func doneBarButtonTap(_ sender: UIBarButtonItem) {
        endEditing()
    }

    @objc private func addButtonTap(_ sender: CustomButton) {
        addCustomAdvertisment()
    }

}

// MARK: - UITextFieldDelegate

extension AddingAdViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
