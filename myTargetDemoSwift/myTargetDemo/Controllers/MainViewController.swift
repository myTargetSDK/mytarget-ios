//
//  MainViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 17.08.2022.
//  Copyright © 2022 Mail.ru Group. All rights reserved.
//

import UIKit
import MyTargetSDK

final class MainViewController: UIViewController {
    
    private enum CellType {
        case advertisment(Advertisment)
        case custom(CustomAdvertisment)
        
        var title: String {
            switch self {
            case .advertisment(let advertisment):
                return advertisment.title
            case .custom(let advertisment):
                return advertisment.title
            }
        }
        
        var description: String {
            switch self {
            case .advertisment(let advertisment):
                return advertisment.description
            case .custom(let advertisment):
                return advertisment.description
            }
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.separatorColor = .separatorColor()
        tableView.backgroundColor = .backgroundColor()
        tableView.tableFooterView = UIView()
        
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuTableViewCell.reuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    private lazy var provider: CustomAdvertismentProvider = .init()
    private var content: [CellType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundColor()
        view.addSubview(tableView)
        
        let titleView = TitleView(frame: CGRect(x: 0, y: 0, width: 150, height: 32))
        titleView.version.text = "SDK version: " + MTRGVersion.currentVersion()
        titleView.title.text = "myTarget Demo"
        navigationItem.titleView = titleView
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTap(_:)))
        
        let bannersDescription = UIDevice.current.userInterfaceIdiom == .pad ? "320x50, 300x250 and 728x90 banners" : "320x50 and 300x250 banners"
        content = [
            .advertisment(.init(title: "Banners", description: bannersDescription, type: .banner)),
            .advertisment(.init(title: "Interstitial Ads", description: "Fullscreen banners", type: .interstitial)),
            .advertisment(.init(title: "Rewarded video", description: "Fullscreen rewarded video", type: .rewarded)),
            .advertisment(.init(title: "Native Ads", description: "Advertisement inside app's content", type: .native)),
            .advertisment(.init(title: "Native Banners", description: "Compact advertisement inside app's content", type: .nativeBanner)),
            .advertisment(.init(title: "In-stream video", description: "Advertisement inside video stream", type: .instream))
        ]
        content.append(contentsOf: provider.receive().map { .custom($0) })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.indexPathForSelectedRow.map { tableView.deselectRow(at: $0, animated: true) } 
    }

    // MARK: - Actions
    
    @objc func addBarButtonTap(_ sender: UIBarButtonItem) {
        let viewController = AddingAdViewController()
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController: UIViewController
        
        switch content[indexPath.row] {
        case .advertisment(let advertisment):
            switch advertisment.type {
            case .banner:
                viewController = BannerSettingsViewController()
            case .instream:
                viewController = InstreamViewController()
            case .interstitial:
                viewController = InterstitialViewController()
            case .native:
                viewController = NativeSettingsViewController()
            case .nativeBanner:
                viewController = NativeBannerViewController()
            case .rewarded:
                viewController = RewardedViewController()
            }
        case .custom(let customAdvertisment):
            switch customAdvertisment.type {
            case .banner:
                viewController = BannerSettingsViewController(slotId: customAdvertisment.slotId,
                                                              query: customAdvertisment.query)
            case .instream:
                viewController = InstreamViewController(slotId: customAdvertisment.slotId,
                                                        query: customAdvertisment.query)
            case .interstitial:
                viewController = InterstitialViewController(slotId: customAdvertisment.slotId,
                                                            query: customAdvertisment.query)
            case .native:
                viewController = NativeViewController(slotId: customAdvertisment.slotId,
                                                      query: customAdvertisment.query)
            case .nativeBanner:
                viewController = NativeBannerViewController(slotId: customAdvertisment.slotId,
                                                            query: customAdvertisment.query)
            case .rewarded:
                viewController = RewardedViewController(slotId: customAdvertisment.slotId,
                                                        query: customAdvertisment.query)
            }
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.reuseIdentifier, for: indexPath) as! MenuTableViewCell
        cell.configure(title: content[indexPath.row].title, description: content[indexPath.row].description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch content[indexPath.row] {
        case .advertisment:
            return false
        case .custom:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              case .custom(let customAd) = content[indexPath.row]
        else {
            return
        }
        
        tableView.beginUpdates()
        provider.remove(customAd)
        content.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
}

// MARK: - AddingAdViewControllerDelegate

extension MainViewController: AddingAdViewControllerDelegate {
    
    func addingAdViewControllerDidAddCustomAdvertisment(_ customAdvertisment: CustomAdvertisment) {
        tableView.beginUpdates()
        provider.add(customAdvertisment)
        content.append(.custom(customAdvertisment))
        tableView.insertRows(at: [.init(row: content.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
        
        navigationController?.popToViewController(self, animated: true)
    }
    
}
