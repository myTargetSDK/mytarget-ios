//
//  MainViewController.swift
//  myTargetDemo
//
//  Created by Andrey Seredkin on 19/06/2019.
//  Copyright © 2019 Mail.Ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

enum AdvertismentType: UInt
{
	case standard
	case interstitial
	case rewarded
	case native
	case nativeBanner
	case instream
}

struct Advertisment
{
	let title: String
	let description: String?
	let type: AdvertismentType
	let slotId: UInt
	let query: [String: String]?
	let isCustom: Bool

	private enum CodingKeys: String
	{
		case title
		case description
		case type
		case slotId
		case isCustom
		case query
	}

	init(title: String,
		 description: String?,
		 type: AdvertismentType,
		 slotId: UInt = 0,
		 query: [String: String]? = nil,
		 isCustom: Bool = false)
	{
		self.title = title
		self.description = description
		self.type = type
		self.slotId = slotId
		self.isCustom = isCustom
		self.query = query
	}

	init(dictionary: [String:Any])
	{
		let title = dictionary[CodingKeys.title.rawValue] as? String
		let description = dictionary[CodingKeys.description.rawValue] as? String
		let type = dictionary[CodingKeys.type.rawValue] as? UInt
		let slotId = dictionary[CodingKeys.slotId.rawValue] as? UInt
		let isCustom = dictionary[CodingKeys.isCustom.rawValue] as? Bool
		let query = dictionary[CodingKeys.query.rawValue] as? [String: String]

		var advertismentType = AdvertismentType.standard
		if let type = type
		{
			advertismentType = AdvertismentType(rawValue: type) ?? .standard
		}

		self.title = title ?? ""
		self.description = description
		self.type = advertismentType
		self.slotId = slotId ?? 0
		self.isCustom = isCustom ?? false
		self.query = query
	}

	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		dictionary[CodingKeys.title.rawValue] = title
		dictionary[CodingKeys.description.rawValue] = description
		dictionary[CodingKeys.type.rawValue] = type.rawValue
		dictionary[CodingKeys.slotId.rawValue] = slotId
		dictionary[CodingKeys.query.rawValue] = query
		dictionary[CodingKeys.isCustom.rawValue] = isCustom
		return dictionary
	}
}

class TitleView: UIView
{
	private let stackView = UIStackView()
	let title = UILabel()
	let version = UILabel()

	override init(frame: CGRect)
	{
		super.init(frame: frame)
		initialize()
	}

	required init?(coder: NSCoder)
	{
		super.init(coder: coder)
		initialize()
	}

	private func initialize()
	{
		title.textAlignment = .center
		version.textAlignment = .center
		title.font = UIFont.systemFont(ofSize: 15)
		version.font = UIFont.systemFont(ofSize: 10)

		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fill
		stackView.addArrangedSubview(title)
		stackView.addArrangedSubview(version)
		addSubview(stackView)
	}

	override func layoutSubviews()
	{
		super.layoutSubviews()
		stackView.frame = bounds
	}
}

protocol AdViewController: AnyObject
{
	var slotId: UInt? { get set }
	var query: [String: String]? { get set }
	func refresh()
	func loadMore()
	func supportsInfiniteScroll() -> Bool
}

extension AdViewController
{
	func refresh() {}
	func loadMore() {}
	func supportsInfiniteScroll() -> Bool { return false }
	
	func setQueryParams(for ad: MTRGBaseAd)
	{
		if let query = self.query, query.count > 0
		{
			for item in query
			{
				ad.customParams.setCustomParam(item.value, forKey: item.key)
			}
		}
	}
}

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
	@IBOutlet weak var tableView: UITableView!

	private let customAdvertismentsKey = "customAdvertismentsKey"
	private var advertisments = [Advertisment]()
	{
		didSet
		{
			tableView.reloadData()
		}
	}

	private var segue: [AdvertismentType: String]
	{
		return [
			.standard: "bannersSegue",
			.interstitial: "interstitialSegue",
			.rewarded: "rewardedSegue",
			.native: "nativeSegue",
			.nativeBanner: "nativeBannerSegue",
			.instream: "instreamSegue"
		]
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()

		MTRGManager.setDebugMode(true)

		if #available(iOS 11.0, *)
		{
			tableView.contentInsetAdjustmentBehavior = .automatic
		}
		else
		{
			automaticallyAdjustsScrollViewInsets = false
		}

		let titleView = TitleView(frame: CGRect(x: 0, y: 0, width: 150, height: 32))
		titleView.version.text = "SDK version: " + MTRGVersion.currentVersion()
		titleView.title.text = "myTarget Demo"
		navigationItem.titleView = titleView
		navigationItem.title = "Main"
		navigationController?.navigationBar.tintColor = UIColor.foregroundColor()

		tableView.delegate = self
		tableView.dataSource = self
		tableView.tableFooterView = UIView()

		tableView.separatorColor = UIColor.separatorColor()
		tableView.backgroundColor = UIColor.backgroundColor()
		view.backgroundColor = UIColor.backgroundColor()
	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)

		let bannersDescription = (UIDevice.current.model == "iPad") ? "320x50, 300x250 and 728x90 banners" : "320x50 and 300x250 banners"
		advertisments = [
			Advertisment(title: "Banners", description: bannersDescription, type: .standard),
			Advertisment(title: "Interstitial", description: "Fullscreen banners", type: .interstitial),
			Advertisment(title: "Rewarded", description: "Rewarded video", type: .rewarded),
			Advertisment(title: "Native Ad", description: "Advertisement inside app's content", type: .native),
			Advertisment(title: "Native Banner Ad", description: "Compact advertisement inside app's content", type: .nativeBanner),
			Advertisment(title: "Instream", description: "Advertisement inside video stream", type: .instream)
		]

		guard let customAds = UserDefaults.standard.array(forKey: customAdvertismentsKey) as? [[String:Any]], !customAds.isEmpty else { return }
		customAds.forEach { advertisments.append(Advertisment(dictionary: $0)) }
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		guard let controller = segue.destination as? AdViewController else { return }
		guard let indexPath = tableView.indexPathForSelectedRow else { return }
		let advertisment = advertisments[indexPath.row]
		controller.slotId = advertisment.isCustom ? advertisment.slotId : nil
		controller.query = advertisment.query
	}

// MARK: - UITableViewDataSource

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return advertisments.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		return tableView.dequeueReusableCell(withIdentifier: "AdTypeCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "AdTypeCell")
	}

	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
	{
		guard editingStyle == .delete else { return }

		tableView.beginUpdates()

		var customAdvertisments = [[String:Any]]()
		advertisments.remove(at: indexPath.row)
		advertisments.filter { $0.isCustom }.forEach { customAdvertisments.append($0.toDictionary()) }
		let userDefaults = UserDefaults.standard
		userDefaults.set(customAdvertisments, forKey: customAdvertismentsKey)
		userDefaults.synchronize()

		tableView.deleteRows(at: [indexPath], with: .automatic)
		tableView.endUpdates()
	}
	
// MARK: - UITableViewDelegate

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
	{
		let advertisment = advertisments[indexPath.row]
		return advertisment.isCustom
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		let advertisment = advertisments[indexPath.row]
		cell.textLabel?.text = advertisment.title
		cell.detailTextLabel?.text = advertisment.description
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let advertisment = advertisments[indexPath.row]
		guard let identifier = segue[advertisment.type] else { return }
		performSegue(withIdentifier: identifier, sender: self)
	}

}
