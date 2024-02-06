//
//  MenuTableViewCell.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 17.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

final class MenuTableViewCell: UITableViewCell {

    static let reuseIdentifier: String = String(describing: MenuTableViewCell.self)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .foregroundColor()
        label.numberOfLines = 1
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .foregroundColor()
        label.numberOfLines = 1
        return label
    }()

    private let titleMargins = UIEdgeInsets(top: 8, left: 16, bottom: 2, right: 16)
    private let descriptionMargins = UIEdgeInsets(top: 2, left: 16, bottom: 8, right: 16)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        accessoryType = .disclosureIndicator
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let contentWidth = contentView.sizeThatFits(frame.size).width

        let titleSize = titleSizeThatFits(contentWidth)
        titleLabel.frame = CGRect(x: titleMargins.left,
                                  y: titleMargins.top,
                                  width: titleSize.width,
                                  height: titleSize.height)

        let descriptionSize = descriptionSizeThatFits(contentWidth)
        descriptionLabel.frame = CGRect(x: descriptionMargins.left,
                                        y: descriptionMargins.top + titleLabel.frame.maxY,
                                        width: descriptionSize.width,
                                        height: descriptionSize.height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let contentWidth = contentView.sizeThatFits(size).width
        let titleSize = titleSizeThatFits(contentWidth)
        let descriptionSize = descriptionSizeThatFits(contentWidth)

        let titleHeightWithMargins = titleMargins.top + titleSize.height + titleMargins.bottom
        let descriptionHeightWithMargins = descriptionMargins.top + descriptionSize.height + descriptionMargins.bottom

        let height = titleHeightWithMargins + descriptionHeightWithMargins
        return .init(width: size.width, height: height)
    }

    func configure(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        setNeedsLayout()
    }

    private func titleSizeThatFits(_ width: CGFloat) -> CGSize {
        let titleWidth = width - (titleMargins.left + titleMargins.right)
        return titleLabel.textRect(forBounds: .init(x: 0,
                                                    y: 0,
                                                    width: titleWidth,
                                                    height: .greatestFiniteMagnitude),
                                   limitedToNumberOfLines: titleLabel.numberOfLines).size
    }

    private func descriptionSizeThatFits(_ width: CGFloat) -> CGSize {
        let descriptionWidth = width - (descriptionMargins.left + descriptionMargins.right)
        return descriptionLabel.textRect(forBounds: .init(x: 0,
                                                          y: 0,
                                                          width: descriptionWidth,
                                                          height: .greatestFiniteMagnitude),
                                         limitedToNumberOfLines: descriptionLabel.numberOfLines).size
    }

}
