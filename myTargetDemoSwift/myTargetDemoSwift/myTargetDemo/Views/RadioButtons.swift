//
//  RadioButtons.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 15/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

final class RadioButtonsView<T: RawRepresentable & CaseIterable>: UIStackView where T.RawValue == String {

    private let title: String
    private(set) var selectedRadioButtonType: T {
        didSet {
            for subview in arrangedSubviews {
                if let button = subview as? RadioButton {
                    button.isSelected = button.radioButtonType == selectedRadioButtonType
                }
            }
        }
    }

    init(title: String) {
        precondition(!T.allCases.isEmpty, "Enum must have at least 1 case")
        self.title = title
        // swiftlint:disable:next force_unwrapping
        self.selectedRadioButtonType = T.allCases.first!
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        spacing = 8

        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .foregroundColor()
        label.text = title
        addArrangedSubview(label)

        for button in T.allCases {
            let radioButton = RadioButton(title: button.rawValue, radioButtonType: button)
            radioButton.isSelected = button == selectedRadioButtonType
            radioButton.onTap = { [weak self] radioButtonType in
                self?.selectedRadioButtonType = radioButtonType
            }
            addArrangedSubview(radioButton)
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }

    func changeEnabled(_ isEnabled: Bool, for radioButtonType: T) {
        for subview in arrangedSubviews {
            if let button = subview as? RadioButton, button.radioButtonType == radioButtonType {
                button.isEnabled = isEnabled
            }
        }
    }

}

// MARK: - RadioButton

private extension RadioButtonsView {

    final class RadioButton: UIButton {

        var onTap: ((T) -> Void)?

        let radioButtonType: T

        init(title: String, radioButtonType: T) {
            self.radioButtonType = radioButtonType
            super.init(frame: .zero)
            setTitle(title, for: .normal)
            setup()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            backgroundColor = .backgroundColor()
            tintColor = .foregroundColor()

            setTitleColor(.foregroundColor(), for: .normal)
            setTitleColor(.disabledColor(), for: .disabled)
            titleLabel?.font = .systemFont(ofSize: 15)

            let activeIcon = drawIcon(isActive: true)
            let inactiveIcon = drawIcon(isActive: false)
            setImage(inactiveIcon, for: .normal)
            setImage(activeIcon, for: .selected)
            setImage(activeIcon, for: [.selected, .highlighted])

            contentHorizontalAlignment = .left
            contentEdgeInsets.right = 8
            titleEdgeInsets.left = 8
            titleEdgeInsets.right = -8

            addTarget(self, action: #selector(self.tapped), for: .touchUpInside)
        }

        private func drawIcon(isActive: Bool) -> UIImage {
            return UIGraphicsImageRenderer(size: .init(width: 16, height: 16)).image { context in
                UIColor.black.setStroke()
                let path = UIBezierPath(ovalIn: context.format.bounds.inset(by: .init(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)))
                path.lineWidth = 1
                path.stroke()

                if isActive {
                    UIColor.black.setFill()
                    let inset = context.format.bounds.size.width / 4
                    UIBezierPath(ovalIn: context.format.bounds.inset(by: .init(top: inset, left: inset, bottom: inset, right: inset))).fill()
                }

            }.withRenderingMode(.alwaysTemplate)
        }

        @objc private func tapped() {
            onTap?(radioButtonType)
        }
    }

}
