//
//  TopicController.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/8/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Alamofire
import Kanna
import TUSafariActivity

class TopicController: ViewController {

    private var activityIndicatorView: ActivityIndicatorView!
    private var bodyCell: TopicBodyCell?
    private var commentCells: [TopicCommentCell] = []
    private var isRefreshing = false { didSet { didSetRefreshing() } }
    private var networkErrorView: NetworkErrorView!
    private var replies: [Reply]?
    private var replyCells: [TopicReplyCell] = []
    private var tableView: UITableView!
    public  var topic: Topic? { didSet { didSetTopic() } }

    override init() {
        super.init()

        hidesBottomBarWhenPushed = true

        navigationItem.largeTitleDisplayMode = .never

        toolbarItems = [
            UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(toggleFavorite)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(showCompose)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ignore)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "flag"), style: .plain, target: self, action: #selector(showReport)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(action)),
        ]
    }

    override func loadView() {
        tableView = UITableView()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        tableView.register(TopicNameCell.self, forCellReuseIdentifier: TopicNameCell.description())
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

        navigationController?.isToolbarHidden = false

        if topic?.clicksCount == nil || !networkErrorView.isHidden { fetchData() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.isToolbarHidden = true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.didSetTopic()
            self.replyCells = (self.replies ?? []).map { _ in TopicReplyCell() }
            self.tableView.reloadData()
        }
    }

    @objc
    private func fetchData() {
        if isRefreshing { return }
        isRefreshing = true
        AF.request(
            baseURL
                .appendingPathComponent("t")
                .appendingPathComponent(String(topic?.id ?? 0)),
            parameters: [
                "p": 1,
            ]
        )
        .responseString { response in
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let doc = try? HTML(html: response.value ?? "", encoding: .utf8)
                let name = doc?.at_css("h1")?.text
                let bodyHTML = doc?.at_css(".topic_content")?.innerHTML
                let clicksCount = Int("(\\d+) 次点击".r?.findFirst(in: doc?.at_css(".header .gray")?.text ?? "")?.group(at: 1) ?? "")
                let favoritesCount = Int("(\\d+) 人收藏".r?.findFirst(in: doc?.at_css(".topic_stats")?.text ?? "")?.group(at: 1) ?? "")
                let repliesCount = Int("^\\d+".r?.findFirst(in: doc?.at_css("#Main .box:nth-child(4) .gray")?.text ?? "")?.matched ?? "")
                let createdAt = "[^·]+前|刚刚|\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}".r?.findFirst(in: doc?.at_css(".header .gray")?.text ?? "")?.matched.trimmingCharacters(in: .whitespacesAndNewlines)
                let isFavorite = ["加入收藏": false, "取消收藏": true][doc?.at_css(".topic_buttons .tb")?.text]
                let favoriteToken = "[^=]+$".r?.findFirst(in: doc?.at_css(".topic_buttons .tb")?["href"] ?? "")?.matched
                let once = Int(doc?.at_css("input[name=once]")?["value"] ?? "")
                let repliesNextPage = Int(doc?.at_css(".page_current + a")?.text ?? "")
                let userJSON = [
                    "name": doc?.at_css(".header .gray a")?.text,
                    "avatar": doc?.at_css(".header .avatar")?["src"],
                ]
                let nodeJSON = [
                    "name": doc?.css(".header a")[2].text,
                    "code": "[^/]+$".r?.findFirst(in: doc?.css(".header a")[2]["href"] ?? "")?.matched,
                ]
                let commentsJSON = doc?.css(".subtle").map {
                    [
                        "bodyHTML": $0.at_css(".topic_content")?.innerHTML,
                        "createdAt": "[^·]+前|刚刚|\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}".r?.findFirst(in: $0.at_css(".fade")?.text ?? "")?.matched.trimmingCharacters(in: .whitespacesAndNewlines),
                    ] as [String: Any?]
                }
                let json = [
                    "id": self.topic?.id,
                    "name": name,
                    "bodyHTML": bodyHTML,
                    "clicksCount": clicksCount,
                    "favoritesCount": favoritesCount,
                    "repliesCount": repliesCount,
                    "createdAt": createdAt,
                    "isFavorite": isFavorite,
                    "favoriteToken": favoriteToken,
                    "once": once,
                    "repliesNextPage": repliesNextPage,
                    "user": userJSON,
                    "node": nodeJSON,
                    "comments": commentsJSON,
                ] as [String: Any?]
                self.topic = try? Topic(json: json)
                let repliesJSON = doc?.css("#Main .box:nth-child(4) .cell[id]").map {
                    [
                        "bodyHTML": $0.at_css(".reply_content")?.innerHTML,
                        "createdAt": ".+前|刚刚|\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}".r?.findFirst(in: $0.at_css(".ago")?.text ?? "")?.matched,
                        "user": [
                            "name": $0.at_css(".dark")?.text,
                            "avatar": $0.at_css(".avatar")?["src"],
                        ],
                    ] as [String: Any?]
                }
                self.replies = (try? [Reply](json: repliesJSON ?? [])) ?? []
                self.replyCells = (self.replies ?? []).map { _ in TopicReplyCell() }
                self.tableView.reloadData()
            } else {
                self.networkErrorView.isHidden = false
            }
            self.isRefreshing = false
        }
    }

    private func fetchReplies() {
        guard let page = topic?.repliesNextPage else { return }
        if isRefreshing { return }
        isRefreshing = true
        AF.request(
            baseURL
                .appendingPathComponent("t")
                .appendingPathComponent(String(topic?.id ?? 0)),
            parameters: [
                "p": page,
            ]
        )
        .responseString { response in
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let doc = try? HTML(html: response.value ?? "", encoding: .utf8)
                self.topic?.repliesNextPage = Int(doc?.at_css(".page_current + a")?.text ?? "")
                let json = doc?.css("#Main .box:nth-child(4) .cell[id]").map {
                    [
                        "bodyHTML": $0.at_css(".reply_content")?.innerHTML,
                        "createdAt": ".+前|刚刚|\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}".r?.findFirst(in: $0.at_css(".ago")?.text ?? "")?.matched,
                        "user": [
                            "name": $0.at_css(".dark")?.text,
                            "avatar": $0.at_css(".avatar")?["src"],
                        ],
                    ] as [String: Any?]
                }
                let replies = (try? [Reply](json: json ?? [])) ?? []
                self.replies = (self.replies ?? []) + replies
                self.replyCells += replies.map { _ in TopicReplyCell() }
                self.tableView.reloadSections(IndexSet([3]), with: .none)
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

    private func didSetTopic() {
        bodyCell = TopicBodyCell()
        commentCells = (topic?.comments ?? []).map { _ in TopicCommentCell() }

        toolbarItems?.first?.image = topic?.isFavorite ?? false ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")

        userActivity?.webpageURL = baseURL
            .appendingPathComponent("t")
            .appendingPathComponent(String(topic?.id ?? 0))
    }

    @objc
    func action(_ barButtonItem: UIBarButtonItem) {
        let url = baseURL
            .appendingPathComponent("t")
            .appendingPathComponent(String(topic?.id ?? 0))
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [TUSafariActivity()])
        activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        present(activityViewController, animated: true)
    }

    @objc
    private func toggleFavorite(_ sender: Any) {
        if ((tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first as? TopicsController)?.user?.once == nil { return signInRequired(sender) }
        showHUD()
        AF.request(
            baseURL
                .appendingPathComponent(topic?.isFavorite ?? false ? "unfavorite" : "favorite")
                .appendingPathComponent("topic")
                .appendingPathComponent(String(topic?.id ?? 0)),
            parameters: [
                "t": topic?.favoriteToken ?? "",
            ],
            headers: [
                "Referer": baseURL.appendingPathComponent("t").appendingPathComponent(String(topic?.id ?? 0)).absoluteString,
            ]
        )
        .responseString { response in
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let doc = try? HTML(html: response.value ?? "", encoding: .utf8)
                self.topic?.favoriteToken = "[^=]+$".r?.findFirst(in: doc?.at_css(".topic_buttons .tb")?["href"] ?? "")?.matched
                self.topic?.isFavorite?.toggle()
            } else {
                self.networkError()
            }
            self.hideHUD()
        }
    }

    @objc
    private func showCompose(_ sender: Any) {
        showCompose(sender, nil)
    }

    internal func showCompose(_ sender: Any, _ reply: Reply? = nil) {
        if ((tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first as? TopicsController)?.user?.once == nil { return signInRequired(sender) }
        let composeController = ComposeController()
        composeController.reply = reply
        composeController.topic = topic
        let navigationController = UINavigationController(rootViewController: composeController)
        navigationController.modalPresentationStyle = sender is UIBarButtonItem ? .popover : .formSheet
        navigationController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        present(navigationController, animated: true)
    }

    @objc
    func ignore(_ barButtonItem: UIBarButtonItem) {
        if ((tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first as? TopicsController)?.user?.once == nil { return signInRequired(barButtonItem) }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "忽略", style: .destructive) { _ in
            self.showHUD()
            AF.request(
                self.baseURL.appendingPathComponent("/ignore/topic/\(self.topic?.id ?? 0)"),
                parameters: [
                    "once": self.topic?.once ?? "",
                ],
                headers: [
                    "Referer": self.baseURL.appendingPathComponent("t").appendingPathComponent(String(self.topic?.id ?? 0)).absoluteString,
                ]
            )
            .response { response in
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

    @objc
    private func showReport(_ barButtonItem: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "举报", style: .destructive) { _ in
            self.report()
        })
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        alertController.popoverPresentationController?.barButtonItem = barButtonItem
        present(alertController, animated: true)
    }

    internal func report() {
        showHUD()
        AF.request(
            URL(string: "https://ruby-china.net/v2ex") ?? .init(fileURLWithPath: "")
        ).response { response in
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let alertController = UIAlertController(title: "已举报", message: "24小时之内将会处理", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "好", style: .default))
                self.present(alertController, animated: true)
            } else {
                self.networkError()
            }
            self.hideHUD()
        }
    }
}

extension TopicController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 3 && replies != nil { return "\(topic?.repliesCount ?? 0) 回复" }
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [
            1,
            topic?.bodyHTML != nil ? 1 : 0,
            topic?.comments?.count ?? 0,
            replies?.count ?? 0,
        ][section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: TopicNameCell.description(), for: indexPath) as? TopicNameCell ?? .init()
            cell.topic = topic
            return cell

        case 1:
            let cell = bodyCell ?? .init()
            cell.topic = topic
            cell.layoutIfNeeded()
            return cell

        case 2:
            let cell = commentCells[indexPath.row]
            cell.comment = topic?.comments?[indexPath.row]
            cell.comment?.index = indexPath.row
            cell.layoutIfNeeded()
            return cell

        case 3:
            let cell = replyCells[indexPath.row]
            cell.reply = replies?[indexPath.row]
            cell.reply?.index = indexPath.row
            cell.layoutIfNeeded()
            return cell

        default:
            return .init()
        }
    }
}

extension TopicController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row == (replies?.count ?? 0) - 1 { fetchReplies() }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 3:
            return UISwipeActionsConfiguration(actions: [
                UIContextualAction(style: .normal, title: "回复") { _, _, completionHandler in
                    completionHandler(true)
                    let cell = tableView.cellForRow(at: indexPath) ?? .init()
                    self.showCompose(cell, self.replies?[indexPath.row])
                },
            ])

        default:
            return UISwipeActionsConfiguration(actions: [])
        }
    }
}
