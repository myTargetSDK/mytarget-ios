//
//  CarouselCollectionCellView.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 14.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class CarouselCollectionCellView: UICollectionViewCell, MTRGPromoCardViewProtocol {

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundColor()
        label.font = .boldSystemFont(ofSize: 17)
        return label
    }()

    private(set) lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .disabledColor()
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private(set) lazy var ctaButtonLabel: UILabel = {
        let label = UILabel()
        label.textColor = .activeColor()
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()

    private(set) lazy var mediaAdView: MTRGMediaAdView = {
        let mediaAdView = MTRGMediaAdView()
        mediaAdView.clipsToBounds = true
        mediaAdView.layer.cornerRadius = 4
        return mediaAdView
    }()

    private let mainHeight: CGFloat = 96
    private let defaultMargin: CGFloat = 8
    private let titleHeight: CGFloat = 24
    private let descriptionHeight: CGFloat = 24

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.cornerRadius = 8
        backgroundColor = .backgroundColor()

        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(ctaButtonLabel)
        contentView.addSubview(mediaAdView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        mediaAdView.frame = .init(x: defaultMargin,
                                  y: defaultMargin,
                                  width: mainHeight - defaultMargin * 2,
                                  height: mainHeight - defaultMargin * 2)

        titleLabel.frame = .init(x: mediaAdView.frame.maxX + defaultMargin,
                                 y: defaultMargin,
                                 width: contentView.frame.width - mediaAdView.frame.width - defaultMargin,
                                 height: titleHeight)

        descriptionLabel.frame = .init(x: titleLabel.frame.origin.x,
                                       y: titleLabel.frame.maxY,
                                       width: titleLabel.frame.width,
                                       height: descriptionHeight)

        ctaButtonLabel.frame = .init(x: titleLabel.frame.origin.x,
                                     y: contentView.frame.height - descriptionHeight - defaultMargin,
                                     width: titleLabel.frame.width,
                                     height: descriptionHeight)
    }

    func height(withCardWidth width: CGFloat) -> CGFloat {
        return mainHeight
    }

}
