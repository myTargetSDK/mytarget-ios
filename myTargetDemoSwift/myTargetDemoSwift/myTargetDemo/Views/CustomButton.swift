//
//  CustomButton.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 23/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

final class CustomButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }

        layer.borderColor = UIColor.foregroundColor().cgColor
    }

	private func setup() {
		layer.borderWidth = 0.3
		layer.cornerRadius = 4.0

        backgroundColor = .backgroundColor()
        setTitleColor(.disabledColor(), for: .disabled)
        setTitleColor(.foregroundColor(), for: .normal)
        layer.borderColor = UIColor.foregroundColor().cgColor
	}
}
