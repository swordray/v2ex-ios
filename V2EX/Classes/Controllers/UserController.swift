//
//  UserController.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/16/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Alamofire
import Kanna

class UserController: ViewController {

    private var activityIndicatorView: ActivityIndicatorView!
    private var isRefreshing = false { didSet { didSetRefreshing() } }
    private var networkErrorView: NetworkErrorView!
    private var noContentView: NoContentView!
    private var tableView: UITableView!
    public  var user: User? { didSet { didSetUser() } }

    override init() {
        super.init()

        navigationItem.largeTitleDisplayMode = .never
    }

    override func loadView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        tableView.register(TopicsCell.self, forCellReuseIdentifier: TopicsCell.description())
        tableView.register(UserHeaderView.self, forHeaderFooterViewReuseIdentifier: UserHeaderView.description())
        view = tableView

        activityIndicatorView = ActivityIndicatorView()
        view.addSubview(activityIndicatorView)

        networkErrorView = NetworkErrorView()
        networkErrorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fetchData)))
        view.addSubview(networkErrorView)

        noContentView = NoContentView()
        noContentView.textLabel?.text = "无内容"
        view.addSubview(noContentView)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        additionalSafeAreaInsets.top = -(navigationController?.navigationBar.intrinsicContentSize.height ?? 0)

        tryUpdateNavigationBarBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets.top = -(navigationController?.navigationBar.intrinsicContentSize.height ?? 0)

        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: animated) }

        tryUpdateNavigationBarBackground()

        if user?.topics == nil || !networkErrorView.isHidden { fetchData() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tryUpdateNavigationBarBackground()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        updateNavigationBarBackground()
    }

    @objc
    private func fetchData() {
        if isRefreshing { return }
        isRefreshing = true
        AF.request(
            baseURL
                .appendingPathComponent("member")
                .appendingPathComponent(user?.name ?? "")
        )
        .responseString { response in
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let doc = try? HTML(html: response.value ?? "", encoding: .utf8)
                let json = [
                    "id": Int("第 (\\d+) 号会员".r?.findFirst(in: doc?.at_css("#Main .box:nth-child(2) .gray")?.text ?? "")?.group(at: 1) ?? ""),
                    "name": self.user?.name,
                    "avatar": "https:\(doc?.at_css(".avatar")?["src"] ?? "")",
                    "isBlocked": doc?.at_css(".super.normal.button")?["value"] == "Unblock",
                    "token": "t=(\\d+)".r?.findFirst(in: doc?.at_css(".super.normal.button")?["onclick"] ?? "")?.group(at: 1),
                    "once": self.user?.once,
                    "createdAt": "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2} \\+\\d{2}:\\d{2}".r?.findFirst(in: doc?.at_css("#Main .box:nth-child(2) .gray")?.text ?? "")?.matched,
                    "topics": doc?.css(".box .cell.item").map {
                        [
                            "id": Int("^/t/(\\d+)".r?.findFirst(in: $0.at_css(".item_title a")?["href"] ?? "")?.group(at: 1) ?? ""),
                            "name": $0.at_css(".item_title a")?.text,
                            "repliesCount": Int($0.at_css(".count_livid")?.text ?? ""),
                            "repliedAt": "[^•]+前|刚刚|\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}".r?.findFirst(in: $0.at_css(".topic_info, .small")?.text ?? "")?.matched.trimmingCharacters(in: .whitespaces),
                            "node": [
                                "name": $0.at_css(".node")?.text,
                                "code": "[^/]+".r?.findFirst(in: $0.at_css(".node")?["href"] ?? "")?.matched,
                            ],
                        ] as [String: Any?]
                    },
                ] as [String: Any?]
                self.user = try? User(json: json)
                self.noContentView.isHidden = self.user?.topics?.count ?? 0 > 0
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
            noContentView.isHidden = true
            if tableView.refreshControl?.isRefreshing ?? false { return }
            activityIndicatorView.startAnimating()
        } else {
            tableView.refreshControl?.endRefreshing()
            activityIndicatorView.stopAnimating()
        }
    }

    private func didSetUser() {
        navigationItem.rightBarButtonItem = user?.once != nil ? UIBarButtonItem(title: "退出登录", style: .plain, target: self, action: #selector(signOut)) : UIBarButtonItem(title: user?.isBlocked == nil ? nil : user?.isBlocked ?? false ? "解除屏蔽" : "屏蔽", style: .plain, target: self, action: #selector(toggleBlock))

        userActivity?.webpageURL = baseURL
            .appendingPathComponent("member")
            .appendingPathComponent(user?.name ?? "")
    }

    @objc
    private func signOut(_ barButtonItem: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "退出登录", style: .destructive) { _ in
            self.showHUD()
            AF.request(
                self.baseURL.appendingPathComponent("signout"),
                parameters: [
                    "once": self.user?.once ?? "",
                ],
                headers: [
                    "Referer": self.baseURL.absoluteString,
                ]
            )
            .responseString { response in
                self.hideHUD()
                if 200..<300 ~= response.response?.statusCode ?? 0 {
                    let navigationController = self.navigationController
                    navigationController?.popViewController(animated: true)
                    (navigationController?.viewControllers.first as? TopicsController)?.signed()
                } else {
                    self.networkError()
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        alertController.popoverPresentationController?.barButtonItem = barButtonItem
        present(alertController, animated: true)
    }

    @objc
    private func toggleBlock(_ barButtonItem: UIBarButtonItem) {
        if ((tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first as? TopicsController)?.user?.once == nil { return signInRequired(barButtonItem) }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: user?.isBlocked ?? false ? "解除屏蔽" : "屏蔽", style: .destructive) { _ in
            self.showHUD()
            AF.request(
                self.baseURL
                    .appendingPathComponent(self.user?.isBlocked ?? false ? "unblock" : "block")
                    .appendingPathComponent(String(self.user?.id ?? 0)),
                parameters: [
                    "t": self.user?.token ?? "",
                ]
            )
            .responseString { response in
                if 200..<300 ~= response.response?.statusCode ?? 0 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.networkError()
                }
                self.hideHUD()
            }
        })
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        alertController.popoverPresentationController?.barButtonItem = barButtonItem
        present(alertController, animated: true)
    }

    private func updateNavigationBarBackground() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let headerView = tableView.headerView(forSection: 0)
        let alpha = self != navigationController?.topViewController || headerView == nil ? 1 : (tableView.contentOffset.y + view.safeAreaInsets.top) / ((headerView?.frame.height ?? 0) - navigationBar.frame.height)
        navigationBar.subviews.first { $0.classForCoder.description() == "_UIBarBackground" }?.alpha = max(0, min(1, alpha))
        navigationItem.title = alpha < 1 ? nil : user?.name
    }

    private func tryUpdateNavigationBarBackground() {
        for interval in [0.001, 0.01, 0.1] {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                self.updateNavigationBarBackground()
            }
        }
    }
}

extension UserController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self != navigationController?.topViewController { return }
        updateNavigationBarBackground()
    }
}

extension UserController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user?.topics?.count ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: UserHeaderView.description()) as? UserHeaderView
        view?.user = user
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopicsCell.description(), for: indexPath) as? TopicsCell ?? .init()
        cell.tableViewStyle = tableView.style
        cell.topic = user?.topics?[indexPath.row]
        return cell
    }
}

extension UserController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicController = TopicController()
        topicController.topic = user?.topics?[indexPath.row]
        topicController.topic?.user = user
        navigationController?.pushViewController(topicController, animated: true)
    }
}
