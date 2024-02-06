//
//  PlayerAdButton.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 22.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

final class PlayerAdButton: UIButton {

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
        backgroundColor = .backgroundColor().withAlphaComponent(0.3)
        layer.borderColor = UIColor.foregroundColor().cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4

        setTitleColor(.foregroundColor(), for: .normal)
        setTitleColor(.disabledColor(), for: .disabled)

        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        titleLabel?.lineBreakMode = .byTruncatingTail

        contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }

}
