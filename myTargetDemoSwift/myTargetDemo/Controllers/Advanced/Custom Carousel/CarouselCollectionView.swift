//
//  CarouselCollectionView.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 14.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class CarouselCollectionView: UICollectionView, MTRGPromoCardSliderProtocol {
    weak var cardSliderDelegate: MTRGPromoCardSliderDelegate?
    var isCardsClickable: Bool = true
    var sliderState: MTRGPromoCardSliderStateProtocol {
        get {
            state
        }
        set {
            (newValue as? State).map { contentOffset = $0.contentOffset }
        }
    }

    private var cards: [MTRGNativePromoCard] = []
    private lazy var state: State = .init(contentOffset: contentOffset)
    private lazy var dummyCell: CarouselCollectionCellView = .init()

    private let reuseIdentifier: String = "Cell"
    private let insets: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
    private let margin: CGFloat = 8

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        super.init(frame: .zero, collectionViewLayout: layout)

        register(CarouselCollectionCellView.self, forCellWithReuseIdentifier: reuseIdentifier)
        delegate = self
        dataSource = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCards(_ cards: [MTRGNativePromoCard]) {
        self.cards = cards
        reloadData()
    }

    func visibleCards() -> [MTRGNativePromoCard] {
        indexPathsForVisibleItems.map { cards[$0.item] }
    }

}

// MARK: - UICollectionViewDelegate

extension CarouselCollectionView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cardSliderDelegate?.onCardClick(cards[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? CarouselCollectionCellView)?.mediaAdView.imageView.cancelLoading()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        state.contentOffset = scrollView.contentOffset
    }

}

// MARK: - UICollectionViewDataSource

extension CarouselCollectionView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = cards[indexPath.item]
        defer {
            cardSliderDelegate?.onRenderCard?(card)
        }

        // swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CarouselCollectionCellView
        cell.titleLabel.text = card.title
        cell.descriptionLabel.text = card.descriptionText
        cell.ctaButtonLabel.text = card.ctaText
        cell.mediaAdView.imageView.image = nil

        if let imageData = card.image {
            if let image = imageData.image {
                cell.mediaAdView.imageView.image = image
            } else if let url = URL(string: imageData.url) {
                cell.mediaAdView.imageView.loadImage(url: url)
            }
        }

        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension CarouselCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - insets.left - insets.right
        return .init(width: width,
                     height: dummyCell.height(withCardWidth: width))
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }

    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }

}

// MARK: - State

private extension CarouselCollectionView {

    final class State: NSObject, MTRGPromoCardSliderStateProtocol {
        var contentOffset: CGPoint

        init(contentOffset: CGPoint) {
            self.contentOffset = contentOffset
        }
    }

}
