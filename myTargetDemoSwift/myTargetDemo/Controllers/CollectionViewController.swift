//
//  CollectionViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 24/07/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit

class FlowLayout: UICollectionViewFlowLayout
{
	//
}

class CollectionCell: UICollectionViewCell
{
	private let lineLayer = CALayer()
	var adView: UIView?
	{
		didSet
		{
			setNeedsLayout()
			layoutIfNeeded()
		}
	}

	override init(frame: CGRect)
	{
		super.init(frame: frame)
		configure()
	}

	required init?(coder: NSCoder)
	{
		super.init(coder: coder)
		configure()
	}

	private func configure()
	{
		lineLayer.backgroundColor = UIColor.separatorColor().cgColor
		layer.addSublayer(lineLayer)
	}

	override func layoutSubviews()
	{
		super.layoutSubviews()

		lineLayer.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 0.6)
		guard let adView = adView else { return }
		adView.frame = CGRect(origin: .zero, size: contentView.frame.size)
	}
}

class CellView: UIView
{
	let titleLabel = UILabel()
	let descriptionLabel = UILabel()
	private let titleMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
	private let descriptionMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

	override init(frame: CGRect)
	{
		super.init(frame: frame)
		configure()
	}

	required init?(coder: NSCoder)
	{
		super.init(coder: coder)
		configure()
	}

	private func configure()
	{
		titleLabel.text = "Lorem ipsum dolor sit amet"
		titleLabel.font = UIFont.systemFont(ofSize: 17)
		self.addSubview(titleLabel)

		descriptionLabel.text = "Lorem ipsum dolor sit amet, error ceteros ex mea, possim equidem verterem cum no. Eum deleniti detraxit ea. Praesent inciderint at quo, at pro munere facete, libris delenit ei cum. Laoreet argumentum his et, mei ne eros paulo delicata. Porro soluta singulis cum ad, pro ad viderer complectitur. At cum illum veritus. Duo in sanctus splendide disputando, sed case tantas eligendi in."
		descriptionLabel.font = UIFont.systemFont(ofSize: 15)
		descriptionLabel.textColor = .lightGray
		descriptionLabel.numberOfLines = 3
		self.addSubview(descriptionLabel)
	}

	override func sizeThatFits(_ size: CGSize) -> CGSize
	{
		return calculateSizeThatFits(size)
	}

	override func layoutSubviews()
	{
		super.layoutSubviews()
		_ = calculateSizeThatFits(frame.size)
	}

	func calculateSizeThatFits(_ parentSize: CGSize) -> CGSize
	{
		var size = CGSize(width: parentSize.width, height: 0.0)

		let titleWidth = parentSize.width - (titleMargins.left + titleMargins.right)
		let titleSize = titleLabel.sizeThatFits(CGSize(width: titleWidth, height: parentSize.height))
		let titleOrigin = CGPoint(x: titleMargins.left, y: titleMargins.top)
		titleLabel.frame = CGRect(origin: titleOrigin, size: titleSize)
		let titleHeight = titleSize.height + (titleMargins.top + titleMargins.bottom)

		let descriptionWidth = parentSize.width - (descriptionMargins.left + descriptionMargins.right)
		let descriptionSize = descriptionLabel.sizeThatFits(CGSize(width: descriptionWidth, height: parentSize.height))
		var descriptionOrigin = CGPoint(x: descriptionMargins.left, y: descriptionMargins.top)
		descriptionOrigin.y += titleHeight
		descriptionLabel.frame = CGRect(origin: descriptionOrigin, size: descriptionSize)
		let descriptionHeight = descriptionSize.height + (descriptionMargins.top + descriptionMargins.bottom)

		size.height = titleHeight + descriptionHeight
		return size
	}
}

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var bottomView: UIView!
	@IBOutlet weak var bottomViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!

	weak var adViewController: AdViewController?
	{
		didSet
		{
			supportsInfiniteScroll = adViewController?.supportsInfiniteScroll() ?? false
		}
	}

	var adViews = [UIView]()
	{
		willSet
		{
			bottomViewWidthConstraint.constant = 0
			bottomViewHeightConstraint.constant = 0
			adViews.forEach { $0.removeFromSuperview() }
		}
		didSet
		{
			isLoading = false
			refreshControl.endRefreshing()
			loadingView?.activityIndicator.stopAnimating()
			setupViews()
			collectionView.reloadData()
		}
	}

	var adSize = CGSize.zero
	var isBottom = false

	private let viewsCount = 15
	private var views = [UIView]()
	private var cellViews = [CellView]()
	private let refreshControl = UIRefreshControl()
	private var loadingView: LoadingReusableView?
	private var isLoading = false
	private var supportsInfiniteScroll = false

	override func viewDidLoad()
	{
		super.viewDidLoad()

		view.backgroundColor = UIColor.backgroundColor()

		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")

		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		if #available(iOS 10, *)
		{
			collectionView.refreshControl = refreshControl
		}
		else
		{
			collectionView.addSubview(refreshControl)
		}

		let loadingReusableNib = UINib(nibName: "LoadingReusableView", bundle: nil)
		collectionView.register(loadingReusableNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LoadingView")

		if let flowLayout = collectionView.collectionViewLayout as? FlowLayout
		{
			let itemSize = CGSize(width: 200, height: 200)
			flowLayout.itemSize = itemSize
			flowLayout.estimatedItemSize = itemSize
		}

		for _ in 0..<viewsCount
		{
			cellViews.append(CellView())
		}
		views.append(contentsOf: cellViews)
	}

	private func setupViews()
	{
		views.removeAll()

		if isBottom
		{
			views.append(contentsOf: cellViews)
			guard let adView = adViews.first else { return }
			bottomViewWidthConstraint.constant = adSize.width
			bottomViewHeightConstraint.constant = adSize.height
			bottomView.addSubview(adView)
		}
		else
		{
			guard adViews.count > 0 else
			{
				views.append(contentsOf: cellViews)
				return
			}
			var index = 0
			for adView in adViews
			{
				views.append(contentsOf: cellViews)
				let position = index * viewsCount + 2
				views.insert(adView, at: position)
				index += 1
			}
		}
	}

	private func loadMore()
	{
		if isLoading { return }
		guard let adViewController = adViewController, supportsInfiniteScroll else { return }
		isLoading = true
		adViewController.loadMore()
	}

	@objc private func refresh()
	{
		if isLoading { return }
		guard let adViewController = adViewController else
		{
			refreshControl.endRefreshing()
			return
		}
		isLoading = true
		adViewController.refresh()

		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0)
		{
			// handle timeout
			self.isLoading = false
			self.refreshControl.endRefreshing()
			self.loadingView?.activityIndicator.stopAnimating()
		}
	}

// MARK: - UICollectionViewDelegate

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
	{
		guard !views.isEmpty, indexPath.row >= 0, indexPath.row < views.count else { return }
		guard let collectionCell = cell as? CollectionCell else { return }
		let view = views[indexPath.row]
		collectionCell.adView = view
		collectionCell.contentView.addSubview(view)
	}

	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
	{
		guard let collectionCell = cell as? CollectionCell, let view = collectionCell.adView else { return }
		view.removeFromSuperview()
	}

	func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath)
	{
		guard supportsInfiniteScroll, elementKind == UICollectionView.elementKindSectionFooter else { return }
		loadingView?.activityIndicator.startAnimating()
		loadMore()
	}

	func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath)
	{
		guard supportsInfiniteScroll, elementKind == UICollectionView.elementKindSectionFooter else { return }
		loadingView?.activityIndicator.stopAnimating()
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
	{
		return supportsInfiniteScroll ? CGSize(width: collectionView.bounds.size.width, height: 30) : .zero
	}

// MARK: - UICollectionViewDataSource

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return views.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		return collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
	{
		guard kind == UICollectionView.elementKindSectionFooter else { return UICollectionReusableView() }
		guard let loadingView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadingView", for: indexPath) as? LoadingReusableView else { return UICollectionReusableView() }
		self.loadingView = loadingView
		return loadingView
	}

// MARK: - UICollectionViewDelegateFlowLayout

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
	{
		guard !views.isEmpty, indexPath.row >= 0, indexPath.row < views.count else { return .zero }
		let view = views[indexPath.row]
		let width = (collectionView.frame.width >= collectionView.frame.height) ? 0.5 * collectionView.frame.width : collectionView.frame.width
		return view.sizeThatFits(CGSize(width: width, height: collectionView.frame.height))
	}
}
