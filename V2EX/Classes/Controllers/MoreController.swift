//
//  MoreController.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 6/17/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class MoreController: ViewController {

    private var tableView: UITableView!

    override init() {
        super.init()

        title = "更多"
    }

    override func loadView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = self
        tableView.delegate = self
        view = tableView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: animated) }
    }
}

extension MoreController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = UITableViewCell()
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "关于"
            return cell

        case 1:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = "GitHub"
            cell.textLabel?.text = "反馈"
            return cell

        case 2:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator
            let diskUsage = URLCache.shared.currentDiskUsage / 1_024 / 1_024
            cell.detailTextLabel?.text = diskUsage > 0 ? "\(diskUsage) MB" : "0"
            cell.textLabel?.text = "缓存"
            return cell

        case 3:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let version = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
            cell.detailTextLabel?.text = "\(shortVersion) (\(version))"
            cell.selectionStyle = .none
            cell.textLabel?.text = "版本"
            return cell

        default:
            return .init()
        }
    }
}

extension MoreController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let webViewController = WebViewController()
            webViewController.title = "关于"
            webViewController.url = baseURL.appendingPathComponent("about")
            navigationController?.pushViewController(webViewController, animated: true)

        case 1:
            let webViewController = WebViewController()
            webViewController.title = "反馈"
            webViewController.url = URL(string: "https://github.com/swordray/v2ex-ios/issues")
            navigationController?.pushViewController(webViewController, animated: true)

        case 2:
            URLCache.shared.removeAllCachedResponses()
            tableView.reloadRows(at: [indexPath], with: .automatic)

        default:
            break
        }
    }
}
