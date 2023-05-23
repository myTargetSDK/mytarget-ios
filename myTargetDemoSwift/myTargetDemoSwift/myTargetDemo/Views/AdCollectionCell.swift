//
//  AdCollectionCell.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 11.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

final class AdCollectionCell: UICollectionViewCell {

    static let reuseIdentifier: String = String(describing: AdCollectionCell.self)

    var adView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            adView.map { contentView.insertSubview($0, belowSubview: line) }
            setNeedsLayout()
        }
    }

    private lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = .separatorColor()
        return view
    }()

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
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        line.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
        adView?.frame = bounds
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return adView?.sizeThatFits(size) ?? .zero
    }

}
