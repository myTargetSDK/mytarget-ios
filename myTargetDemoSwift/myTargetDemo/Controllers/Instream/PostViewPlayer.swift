//
//  PostViewPlayer.swift
//  myTargetDemo
//
//  Created by Sorokin Igor on 31.01.2025.
//  Copyright © 2025 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

protocol PostViewPlayerViewDelegate: AnyObject {
    func onCtaButtonClick()
}

final class PostViewPlayer: UIView {
    weak var delegate: PostViewPlayerViewDelegate?

    var callToAction: CallToActionData?

    private let backgroundImageView = UIImageView()
    private let overlayView = UIView()
    private let containerBackgroundView = UIView()
    private let containerStackView = UIStackView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let ctaButton = UIButton()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupConstraints()
    }
}

extension PostViewPlayer: InstreamAdPostViewPlayer {

    func show(postViewData: PostViewData) {
        backgroundImageView.image = postViewData.backgroundImage?.image
        overlayView.backgroundColor = postViewData.overlayViewColor
        titleLabel.text = callToAction?.additionalText
        iconImageView.image = callToAction?.icon?.image
        descriptionLabel.text = postViewData.text
        ctaButton.backgroundColor = callToAction?.buttonColor
        ctaButton.setTitleColor(callToAction?.buttonTextColor, for: .normal)
        ctaButton.setTitle(callToAction?.buttonText, for: .normal)
    }

    func update(progress: TimeInterval, duration: TimeInterval) {
        // no op
    }

    func hide() {
        // hides from InstreamViewController
    }
}

private extension PostViewPlayer {

    @objc func ctaButtonTapped() {
        delegate?.onCtaButtonClick()
    }

    private func setup() {
        backgroundImageView.contentMode = .scaleAspectFit

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = Constants.cornerRadius
        iconImageView.clipsToBounds = true

        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        ctaButton.layer.cornerRadius = Constants.cornerRadius
        ctaButton.addTarget(self, action: #selector(ctaButtonTapped), for: .touchUpInside)

        containerStackView.axis = .vertical
        containerStackView.spacing = Constants.spacing

        containerBackgroundView.backgroundColor = .black
        containerBackgroundView.alpha = 0.3
        containerBackgroundView.layer.cornerRadius = Constants.cornerRadius

        addSubview(backgroundImageView)
        addSubview(overlayView)
        addSubview(containerBackgroundView)
        addSubview(containerStackView)

        containerStackView.addArrangedSubview(iconImageView)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(descriptionLabel)
        containerStackView.addArrangedSubview(ctaButton)
    }

    private func setupConstraints() {
        [backgroundImageView,
         overlayView,
         containerBackgroundView,
         containerStackView,
         iconImageView,
         titleLabel,
         descriptionLabel,
         ctaButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerBackgroundView.topAnchor.constraint(equalTo: containerStackView.topAnchor, constant: -Constants.spacing),
            containerBackgroundView.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor, constant: -Constants.spacing),
            containerBackgroundView.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor, constant: Constants.spacing),
            containerBackgroundView.bottomAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: Constants.spacing),

            containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),

            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSide),
            ctaButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    private enum Constants {
        static let spacing: CGFloat = 8
        static let cornerRadius: CGFloat = 10
        static let buttonHeight: CGFloat = 30
        static let iconSide: CGFloat = 45
    }
}
