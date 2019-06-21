//
//  NodesController.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/19/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Alamofire
import Kanna

class NodesController: ViewController {

    private var activityIndicatorView: ActivityIndicatorView!
    private var isRefreshing = false { didSet { didSetRefreshing() } }
    private var networkErrorView: NetworkErrorView!
    private var sections: [Section] = []
    private var tableView: UITableView!

    override init() {
        super.init()

        title = "节点"
    }

    override func loadView() {
        tableView = UITableView()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        tableView.tableFooterView = UIView()
        view = tableView

        activityIndicatorView = ActivityIndicatorView()
        view.addSubview(activityIndicatorView)

        networkErrorView = NetworkErrorView()
        networkErrorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fetchData)))
        view.addSubview(networkErrorView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerForPreviewing(with: self, sourceView: tableView)

        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: animated) }

        if sections.count == 0 || !networkErrorView.isHidden { fetchData() }
    }

    @objc
    private func fetchData() {
        if isRefreshing { return }
        isRefreshing = true
        Alamofire.request(
            baseURL
        )
        .responseString { response in
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let doc = try? HTML(html: response.value ?? "", encoding: .utf8)
                let json = doc?.css("#Main .box:nth-child(4) .cell:not(:first-child)").map {
                    [
                        "name": $0.at_css(".fade")?.text,
                        "nodes": $0.css("a").map {
                            [
                                "name": $0.text,
                                "code": "[^/]+$".r?.findFirst(in: $0["href"] ?? "")?.matched,
                            ]
                        },
                    ] as [String: Any?]
                }
                self.sections = (try? [Section](json: json ?? [])) ?? []
                self.tableView.reloadData()
            } else {
                self.networkErrorView.isHidden = false
            }
            self.isRefreshing = false
        }
    }

    private func didSetRefreshing() {
        if isRefreshing {
            networkErrorView.isHidden = true
            if tableView.refreshControl?.isRefreshing ?? false { return }
            activityIndicatorView.startAnimating()
        } else {
            tableView.refreshControl?.endRefreshing()
            activityIndicatorView.stopAnimating()
        }
    }
}

extension NodesController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].nodes.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = sections[indexPath.section].nodes[indexPath.row].name
        return cell
    }
}

extension NodesController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicsController = TopicsController()
        topicsController.node = sections[indexPath.section].nodes[indexPath.row]
        navigationController?.pushViewController(topicsController, animated: true)
    }
}

extension NodesController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        previewingContext.sourceRect = cell.frame
        let topicsController = TopicsController()
        topicsController.node = sections[indexPath.section].nodes[indexPath.row]
        return topicsController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
