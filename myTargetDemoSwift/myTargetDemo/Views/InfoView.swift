//
//  InfoView.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 19.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit

final class InfoView<T: RawRepresentable & CaseIterable>: UIStackView where T.RawValue == String {

    private let title: String
    private let doubleColumns: Bool

    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8

        let columnCount = doubleColumns ? 2 : 1
        for _ in 0..<columnCount {
            let subStack = UIStackView()
            subStack.axis = .vertical
            subStack.alignment = .fill
            subStack.distribution = .fillEqually
            subStack.spacing = 8
            stack.addArrangedSubview(subStack)
        }

        return stack
    }()

    init(title: String, doubleColumns: Bool = false) {
        precondition(!T.allCases.isEmpty, "Enum must have at least 1 case")
        self.title = title
        self.doubleColumns = doubleColumns
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        axis = .vertical
        alignment = .fill
        distribution = .fill
        spacing = 8

        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .foregroundColor()
        label.text = title
        addArrangedSubview(label)

        let infos = T.allCases
        for (index, info) in infos.enumerated() {
            let field = FieldView(title: info.rawValue + ":", forDoubleColumns: doubleColumns)
            let column = stack.arrangedSubviews[index * stack.arrangedSubviews.count / infos.count] as? UIStackView
            column?.addArrangedSubview(field)
        }
        addArrangedSubview(stack)
    }

    subscript(field: T) -> String? {
        // swiftlint:disable force_unwrapping
        get {
            let infos = T.allCases
            let index = infos.distance(from: infos.startIndex, to: infos.firstIndex(where: { $0 == field })!)
            let column = stack.arrangedSubviews[index * stack.arrangedSubviews.count / infos.count] as? UIStackView
            let fieldView = column?.arrangedSubviews[index % ((infos.count + 1) / stack.arrangedSubviews.count)] as? FieldView
            return fieldView?.valueText
        }
        set {
            let infos = T.allCases
            let index = infos.distance(from: infos.startIndex, to: infos.firstIndex(where: { $0 == field })!)
            let column = stack.arrangedSubviews[index * stack.arrangedSubviews.count / infos.count] as? UIStackView
            let fieldView = column?.arrangedSubviews[index % ((infos.count + 1) / stack.arrangedSubviews.count)] as? FieldView
            fieldView?.valueText = newValue
        }
        // swiftlint:enable force_unwrapping
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }

    func clear() {
        for arrangedSubviews in stack.arrangedSubviews {
            for subview in arrangedSubviews.subviews {
                if let fieldView = subview as? FieldView {
                    fieldView.valueText = FieldView.emptyText
                }
            }
        }
    }

}

private extension InfoView {

    final class FieldView: UIView {

        var valueText: String? {
            get {
                return valueLabel.text
            }
            set {
                valueLabel.text = newValue
            }
        }

        static var emptyText: String { "n/a" }

        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 1
            label.font = .systemFont(ofSize: 15)
            label.textColor = .foregroundColor()
            return label
        }()

        private lazy var valueLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 1
            label.font = .systemFont(ofSize: 15, weight: .bold)
            label.textColor = .foregroundColor()
            label.text = FieldView.emptyText
            return label
        }()

        private let forDoubleColumns: Bool
        private var titleFraction: CGFloat {
            forDoubleColumns ? 0.6 : 0.3
        }
        private var valueFraction: CGFloat {
            1 - titleFraction
        }

        override var intrinsicContentSize: CGSize {
            sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude,
                               height: CGFloat.greatestFiniteMagnitude))
        }

        init(title: String, forDoubleColumns: Bool) {
            self.forDoubleColumns = forDoubleColumns
            super.init(frame: .zero)
            titleLabel.text = title
            setup()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            addSubview(titleLabel)
            addSubview(valueLabel)
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            titleLabel.frame = CGRect(origin: .zero,
                                      size: .init(width: frame.width * titleFraction, height: frame.height))
            valueLabel.frame = CGRect(origin: .init(x: frame.width * titleFraction, y: 0),
                                      size: .init(width: frame.width * valueFraction, height: frame.height))
        }

        override func sizeThatFits(_ size: CGSize) -> CGSize {
            let titleSize = titleSizeThatFits(size.width * titleFraction)
            let valueSize = valueSizeThatFits(size.width * valueFraction)
            return .init(width: titleSize.width + valueSize.width,
                         height: max(valueSize.height, titleSize.height))
        }

        private func titleSizeThatFits(_ width: CGFloat) -> CGSize {
            return titleLabel.textRect(forBounds: .init(x: 0,
                                                        y: 0,
                                                        width: width,
                                                        height: .greatestFiniteMagnitude),
                                       limitedToNumberOfLines: titleLabel.numberOfLines).size
        }

        private func valueSizeThatFits(_ width: CGFloat) -> CGSize {
            return valueLabel.textRect(forBounds: .init(x: 0,
                                                        y: 0,
                                                        width: width,
                                                        height: .greatestFiniteMagnitude),
                                       limitedToNumberOfLines: valueLabel.numberOfLines).size
        }

    }

}
