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
	case native
	case instream
}

struct Advertisment
{
	let title: String
	let description: String?
	let type: AdvertismentType
	let slotId: UInt
	let isCustom: Bool

	private enum CodingKeys: String
	{
		case title
		case description
		case type
		case slotId
		case isCustom
	}

	init(title: String, description: String?, type: AdvertismentType, slotId: UInt = 0, isCustom: Bool = false)
	{
		self.title = title
		self.description = description
		self.type = type
		self.slotId = slotId
		self.isCustom = isCustom
	}

	init(dictionary: [String:Any])
	{
		let title = dictionary[CodingKeys.title.rawValue] as? String
		let description = dictionary[CodingKeys.description.rawValue] as? String
		let type = dictionary[CodingKeys.type.rawValue] as? UInt
		let slotId = dictionary[CodingKeys.slotId.rawValue] as? UInt
		let isCustom = dictionary[CodingKeys.isCustom.rawValue] as? Bool

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
	}

	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		dictionary[CodingKeys.title.rawValue] = title
		dictionary[CodingKeys.description.rawValue] = description
		dictionary[CodingKeys.type.rawValue] = type.rawValue
		dictionary[CodingKeys.slotId.rawValue] = slotId
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

	override func viewDidLoad()
	{
		super.viewDidLoad()

		MTRGAdView.setDebugMode(true)

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
			Advertisment(title: "Native Ads", description: "Advertisement inside app's content", type: .native),
			Advertisment(title: "Instream", description: "Advertisement inside video stream", type: .instream)
		]

		guard let customAds = UserDefaults.standard.array(forKey: customAdvertismentsKey) as? [[String:Any]], !customAds.isEmpty else { return }
		customAds.forEach { advertisments.append(Advertisment(dictionary: $0)) }
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		guard let indexPath = tableView.indexPathForSelectedRow else { return }
		let advertisment = advertisments[indexPath.row]

		if segue.identifier == "bannersSegue", let controller = segue.destination as? StandardViewController
		{
			controller.slotId = advertisment.isCustom ? advertisment.slotId : nil
		}
		else if segue.identifier == "interstitialSegue", let controller = segue.destination as? InterstitialViewController
		{
			controller.slotId = advertisment.isCustom ? advertisment.slotId : nil
		}
		else if segue.identifier == "nativeSegue", let controller = segue.destination as? NativeViewController
		{
			controller.slotId = advertisment.isCustom ? advertisment.slotId : nil
		}
		else if segue.identifier == "instreamSegue", let controller = segue.destination as? InstreamViewController
		{
			controller.slotId = advertisment.isCustom ? advertisment.slotId : nil
		}
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
		switch advertisment.type
		{
			case .standard:
				performSegue(withIdentifier: "bannersSegue", sender: self)
				break
			case .interstitial:
				performSegue(withIdentifier: "interstitialSegue", sender: self)
				break
			case .native:
				performSegue(withIdentifier: "nativeSegue", sender: self)
				break
			case .instream:
				performSegue(withIdentifier: "instreamSegue", sender: self)
				break
		}
	}

}

