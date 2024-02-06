//
//  LoadingReusableView.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 13/05/2020.
//  Copyright © 2020 Mail.Ru Group. All rights reserved.
//

import UIKit

final class LoadingReusableView: UICollectionReusableView {

    static let reuseIdentifier: String = String(describing: LoadingReusableView.self)

    private lazy var activityIndicator: UIActivityIndicatorView = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let activityIndicatorSize = activityIndicator.sizeThatFits(frame.size)
        activityIndicator.frame = CGRect(x: (frame.width - activityIndicatorSize.width) / 2,
                                         y: (frame.height - activityIndicatorSize.height) / 2,
                                         width: activityIndicatorSize.width,
                                         height: activityIndicatorSize.height)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.startAnimating()
    }

}
