//
//  TitleView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19/06/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

final class TitleView: UIView {
    private let stackView = UIStackView()
    let title = UILabel()
    let version = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        title.textAlignment = .center
        version.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 15)
        version.font = UIFont.systemFont(ofSize: 10)

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(version)
        addSubview(stackView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
    }
}
