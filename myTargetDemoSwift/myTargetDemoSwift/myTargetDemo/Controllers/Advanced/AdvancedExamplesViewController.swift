//
//  AdvancedExamplesViewController.swift
//  myTargetDemo
//
//  Created by Alexander Vorobyev on 14.02.2023.
//  Copyright © 2023 Mail.ru Group. All rights reserved.
//

import UIKit

final class AdvancedExamplesViewController: UIViewController {

    private enum CellType {
        case menuItem(MenuItem<AdvancedExamplesRoute>)

        var title: String {
            switch self {
            case .menuItem(let menuItem):
                return menuItem.title
            }
        }

        var description: String {
            switch self {
            case .menuItem(let menuItem):
                return menuItem.description
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

    private var content: [CellType] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Advanced Examples"

        view.backgroundColor = .backgroundColor()
        view.addSubview(tableView)

        content.append(.menuItem(.init(title: "Custom carousel",
                                       description: "Native Ads",
                                       route: .customCarousel)))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.indexPathForSelectedRow.map { tableView.deselectRow(at: $0, animated: true) }
    }
}

// MARK: - UITableViewDelegate

extension AdvancedExamplesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController: UIViewController

        switch content[indexPath.row] {
        case .menuItem(let menuItem):
            switch menuItem.route {
            case .customCarousel:
                viewController = CustomCarouselViewController()
            }
        }

        navigationController?.pushViewController(viewController, animated: true)
    }

}

// MARK: - UITableViewDataSource

extension AdvancedExamplesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.reuseIdentifier, for: indexPath) as! MenuTableViewCell
        cell.configure(title: content[indexPath.row].title, description: content[indexPath.row].description)
        return cell
    }

}
