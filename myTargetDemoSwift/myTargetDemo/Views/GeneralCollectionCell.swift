//
//  GeneralCollectionCell.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 11.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

final class GeneralCollectionCell: UICollectionViewCell {

    static let reuseIdentifier: String = String(describing: GeneralCollectionCell.self)

    private lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .separatorColor()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet"
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        // swiftlint:disable:next line_length
        label.text = "Lorem ipsum dolor sit amet, error ceteros ex mea, possim equidem verterem cum no. Eum deleniti detraxit ea. Praesent inciderint at quo, at pro munere facete, libris delenit ei cum. Laoreet argumentum his et, mei ne eros paulo delicata. Porro soluta singulis cum ad, pro ad viderer complectitur. At cum illum veritus. Duo in sanctus splendide disputando, sed case tantas eligendi in."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .lightGray
        label.numberOfLines = 3
        return label
    }()

    private let titleMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    private let descriptionMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.addSubview(line)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        line.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)

        let titleSize = titleSizeThatFits(frame.width)
        titleLabel.frame = CGRect(x: titleMargins.left,
                                  y: titleMargins.top,
                                  width: titleSize.width,
                                  height: titleSize.height)

        let descriptionSize = descriptionSizeThatFits(frame.width)
        descriptionLabel.frame = CGRect(x: descriptionMargins.left,
                                        y: descriptionMargins.top + titleLabel.frame.maxY,
                                        width: descriptionSize.width,
                                        height: descriptionSize.height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let titleSize = titleSizeThatFits(size.width)
        let descriptionSize = descriptionSizeThatFits(size.width)

        let titleHeightWithMargins = titleMargins.top + titleSize.height + titleMargins.bottom
        let descriptionHeightWithMargins = descriptionMargins.top + descriptionSize.height + descriptionMargins.bottom

        let height = titleHeightWithMargins + descriptionHeightWithMargins
        return .init(width: size.width, height: height)
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
