//
//  InputView.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 23.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

final class InputView: UIView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15)
        label.textColor = .foregroundColor()
        return label
    }()

    private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 14)
        textField.textColor = .foregroundColor()
        textField.borderStyle = .roundedRect
        textField.adjustsFontSizeToFitWidth = true
        return textField
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title + ":"
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(titleLabel)
        addSubview(textField)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.frame = CGRect(x: 0,
                                  y: 0,
                                  width: frame.width * 0.3,
                                  height: frame.height)
        textField.frame = CGRect(x: titleLabel.frame.maxX,
                                 y: 0,
                                 width: frame.width - titleLabel.frame.maxX,
                                 height: frame.height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = textField.sizeThatFits(size).height
        return .init(width: size.width, height: min(height, size.height))
    }

}
