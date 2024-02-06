//
//  CustomNativeAdView.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 14.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class CustomNativeAdView: UIView {

    private(set) lazy var adLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 9)
        label.textColor = .disabledColor()
        return label
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .foregroundColor()
        return label
    }()

    private(set) lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .disabledColor()
        return label
    }()

    private(set) lazy var iconAdView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private(set) lazy var mediaAdView: CarouselCollectionView = {
        let collectionView = CarouselCollectionView()
        collectionView.backgroundColor = .lightGrayColor()
        return collectionView
    }()

    private(set) lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .foregroundColor()
        return label
    }()

    private(set) lazy var ratingStarsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .disabledColor()
        label.textAlignment = .right
        return label
    }()

    private(set) lazy var votesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .disabledColor()
        label.textAlignment = .right
        return label
    }()

    private(set) lazy var buttonView: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitleColor(.activeColor(), for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.activeColor().cgColor
        return button
    }()

    private var previousWidth: CGFloat = 0

    private let defaultMargin: CGFloat = 8
    private let iconSize: CGSize = .init(width: 64, height: 64)
    private let mediaHeight: CGFloat = 256
    private let titleHeight: CGFloat = 24
    private let descriptionHeight: CGFloat = 22
    private let buttonHeight: CGFloat = 48

    init(banner: MTRGNativePromoBanner) {
        super.init(frame: .zero)

        setup()
        configure(with: banner)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .backgroundColor()
        layer.cornerRadius = 8

        addSubview(adLabel)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(iconAdView)
        addSubview(mediaAdView)
        addSubview(categoryLabel)
        addSubview(ratingStarsLabel)
        addSubview(votesLabel)
        addSubview(buttonView)
    }

    private func configure(with banner: MTRGNativePromoBanner) {
        adLabel.text = banner.advertisingLabel
        titleLabel.text = banner.title
        descriptionLabel.text = banner.descriptionText

        if let iconData = banner.icon {
            if let image = iconData.image {
                iconAdView.image = image
            } else if let url = URL(string: iconData.url) {
                iconAdView.loadImage(url: url)
            }
        }

        mediaAdView.setCards(banner.cards)
        categoryLabel.text = banner.category
        ratingStarsLabel.text = "⭐️ \((banner.rating ?? 0).stringValue)"
        votesLabel.text = "\(banner.votes) vote(s)"
        buttonView.setTitle(banner.ctaText, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        adLabel.sizeToFit()
        adLabel.frame.origin = .init(x: defaultMargin,
                                     y: defaultMargin)

        iconAdView.frame = .init(x: defaultMargin,
                                 y: adLabel.frame.maxY + defaultMargin,
                                 width: iconSize.width,
                                 height: iconSize.height)

        titleLabel.frame = .init(x: iconAdView.frame.maxX + defaultMargin,
                                 y: iconAdView.frame.origin.y + defaultMargin,
                                 width: frame.width - iconAdView.frame.maxX - defaultMargin * 2,
                                 height: titleHeight)

        descriptionLabel.frame = .init(x: titleLabel.frame.origin.x,
                                       y: titleLabel.frame.maxY + defaultMargin / 2,
                                       width: titleLabel.frame.width,
                                       height: descriptionHeight)

        mediaAdView.frame = .init(x: 0,
                                  y: iconAdView.frame.maxY + defaultMargin,
                                  width: frame.width,
                                  height: mediaHeight)

        categoryLabel.frame = .init(x: defaultMargin,
                                  y: mediaAdView.frame.maxY + defaultMargin,
                                  width: frame.width / 2 - defaultMargin * 2,
                                  height: titleHeight)

        ratingStarsLabel.frame = .init(x: frame.width / 2 + defaultMargin,
                                       y: mediaAdView.frame.maxY + defaultMargin,
                                       width: frame.width / 2 - defaultMargin * 2,
                                       height: descriptionHeight)

        votesLabel.frame = .init(x: ratingStarsLabel.frame.origin.x,
                                 y: ratingStarsLabel.frame.maxY,
                                 width: ratingStarsLabel.frame.width,
                                 height: descriptionHeight)

        buttonView.frame = .init(x: defaultMargin,
                                 y: votesLabel.frame.maxY + defaultMargin,
                                 width: frame.width - defaultMargin * 2,
                                 height: buttonHeight)

        let diff = buttonView.frame.maxY + defaultMargin - sizeThatFits(frame.size).height
        if diff > 0 {
            mediaAdView.frame.size.height -= diff
            [categoryLabel, ratingStarsLabel, votesLabel, buttonView].forEach { $0.frame.origin.y -= diff }
        }

        if frame.size.width != previousWidth {
            previousWidth = frame.size.width
            mediaAdView.collectionViewLayout.invalidateLayout()
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height: CGFloat = 0
        let adLabelSize = adLabel.sizeThatFits(size)

        height += defaultMargin + adLabelSize.height
        height += defaultMargin + iconSize.height
        height += defaultMargin + mediaHeight
        height += defaultMargin + descriptionHeight * 2
        height += defaultMargin + buttonHeight
        height += defaultMargin

        return .init(width: size.width, height: min(height, size.height))
    }

}
