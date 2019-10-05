//
//  TopicsController.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/7/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Alamofire
import Kanna
import KeychainAccess

class TopicsController: ViewController {

    private var activityIndicatorView: ActivityIndicatorView!
    private var isRefreshing = false { didSet { didSetRefreshing() } }
    private var networkErrorView: NetworkErrorView!
    public  var node = Node.all { didSet { didSetNode() } }
    private var nodesView: TopicsNodesView?
    private var noContentView: NoContentView!
    private var tableView: UITableView!
    private var topics: [Topic] = []
    private var topicsIsLoaded = false
    private var topicsNextPage = 1
    public  var user: User? { didSet { didSetUser() } }

    override func loadView() {
        tableView = UITableView()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        tableView.register(TopicsCell.self, forCellReuseIdentifier: TopicsCell.description())
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        tableView.tableFooterView = UIView()
        tableView.verticalScrollIndicatorInsets.top = self == navigationController?.viewControllers.first ? 44 : 0
        view = tableView

        activityIndicatorView = ActivityIndicatorView()
        view.addSubview(activityIndicatorView)

        networkErrorView = NetworkErrorView()
        networkErrorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fetchData)))
        view.addSubview(networkErrorView)

        noContentView = NoContentView()
        noContentView.textLabel?.text = "无内容"
        view.addSubview(noContentView)

        nodesView = self == navigationController?.viewControllers.first ? TopicsNodesView() : nil
        tableView.tableHeaderView = nodesView
        nodesView?.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(44)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        nodesView?.contentInset.left = view.layoutMargins.left - view.safeAreaInsets.left
        nodesView?.contentInset.right = view.layoutMargins.right - view.safeAreaInsets.right
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        nodesView?.contentInset.left = view.layoutMargins.left - view.safeAreaInsets.left
        nodesView?.contentInset.right = view.layoutMargins.right - view.safeAreaInsets.right
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = self == navigationController?.viewControllers.first ? Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String : node.name

        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: animated) }

        if topics.count == 0 && !topicsIsLoaded || !networkErrorView.isHidden { fetchData() }
    }

    @objc
    func fetchData() {
        if activityIndicatorView.isAnimating { tableView.refreshControl?.endRefreshing() }
        if isRefreshing { return }
        isRefreshing = true
        AF.request(
            self != navigationController?.viewControllers.first ? baseURL.appendingPathComponent("go").appendingPathComponent(node.code ?? "") : node.code == Node.all.code && topics.count > 0 && !(tableView.refreshControl?.isRefreshing ?? false) ? baseURL.appendingPathComponent("recent") : baseURL,
            parameters: [
                "p": tableView.refreshControl?.isRefreshing ?? false ? 1 : topicsNextPage,
                "tab": node.code ?? "",
            ]
        )
        .responseString { response in
            if self.tableView.refreshControl?.isRefreshing ?? false {
                self.topics = []
                self.topicsIsLoaded = false
            }
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let doc = try? HTML(html: response.value ?? "", encoding: .utf8)
                if self == self.navigationController?.viewControllers.first {
                    let userJSON = [
                        "name": doc?.at_css("#Top td:nth-child(3) a:nth-child(2)")?.text,
                        "avatar": "https:\(doc?.at_css("#Rightbar .box:nth-child(2) .avatar")?["src"] ?? "")",
                        "once": "\\d{5}".r?.findFirst(in: doc?.at_css("#Top td:nth-child(3) a:last-child")?["onclick"] ?? "")?.matched,
                    ]
                    self.user = try? User(json: userJSON)
                }
                if self.nodesView != nil && self.nodesView?.nodes == nil {
                    let nodesJSON = doc?.css("#Tabs a").map {
                        [
                            "name": $0.text,
                            "code": "[^=]+$".r?.findFirst(in: $0["href"] ?? "")?.matched,
                        ]
                    }
                    self.nodesView?.nodes = (try? [Node](json: nodesJSON ?? []))?.filter { $0.code != Node.all.code }
                }
                self.topicsIsLoaded = doc?.at_css(".normal_page_right:not(.disable_now)") == nil && (self.node.code != Node.all.code || self.topics.count > 0 && !(self.tableView.refreshControl?.isRefreshing ?? false) || self.user?.once == nil)
                self.topicsNextPage = Int(doc?.at_css(".page_current + a")?.text ?? "") ?? 1
                let json = doc?.css("#Main .cell.item, #TopicsNode .cell").map {
                    [
                        "id": Int("^/t/(\\d+)".r?.findFirst(in: $0.at_css(".item_title a")?["href"] ?? "")?.group(at: 1) ?? ""),
                        "name": $0.at_css(".item_title a")?.text,
                        "repliesCount": Int($0.at_css(".count_livid")?.text ?? ""),
                        "repliedAt": "[^•]+前|刚刚|\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}".r?.findFirst(in: ($0.at_css(".topic_info") ?? $0.at_css(".small"))?.text ?? "")?.matched.trimmingCharacters(in: .whitespaces),
                        "isSticky": "corner_star".r?.matches($0["style"] ?? ""),
                        "user": [
                            "name": $0.at_css("strong")?.text,
                            "avatar": "https:\($0.at_css("img")?["src"] ?? "")",
                        ],
                        "node": [
                            "name": $0.at_css(".node")?.text,
                            "code": "[^/]+".r?.findFirst(in: $0.at_css(".node")?["href"] ?? "")?.matched,
                        ],
                    ] as [String: Any?]
                }
                self.topics += (try? [Topic](json: json ?? [])) ?? []
                self.noContentView.isHidden = self.topics.count > 0
            } else {
                self.networkErrorView.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.fetchData()
                }
            }
            self.tableView.reloadData()
            self.isRefreshing = false
        }
    }

    private func didSetRefreshing() {
        if isRefreshing {
            networkErrorView.isHidden = true
            noContentView.isHidden = true
            nodesView?.isEnabled = false
            if tableView.refreshControl?.isRefreshing ?? false { return }
            activityIndicatorView.startAnimating()
        } else {
            nodesView?.isEnabled = true
            tableView.refreshControl?.endRefreshing()
            activityIndicatorView.stopAnimating()
        }
    }

    private func didSetNode() {
        userActivity?.webpageURL = self == navigationController?.viewControllers.first ? baseURL : baseURL.appendingPathComponent("go").appendingPathComponent(node.code ?? "")

        if isViewLoaded { refetchData() }
    }

    private func didSetUser() {
        if user == nil {
            navigationItem.rightBarButtonItem = nil
        } else if user?.once == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: self, action: #selector(showSignIn))
        } else {
            let imageView = UIImageView()
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUser)))
            imageView.backgroundColor = .secondarySystemBackground
            imageView.clipsToBounds = true
            imageView.isUserInteractionEnabled = true
            imageView.layer.cornerRadius = 14
            imageView.setImage(withURL: user?.avatar)
            imageView.snp.makeConstraints { $0.size.equalTo(28) }
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        }
    }

    private func refetchData() {
        topics = []
        topicsIsLoaded = false
        topicsNextPage = 1
        tableView.reloadData()
        fetchData()
    }

    internal func signed() {
        user = nil
        refetchData()
    }

    @objc
    private func showUser() {
        let userController = UserController()
        userController.user = user
        navigationController?.pushViewController(userController, animated: true)
    }

    @objc
    internal func showSignIn(_ sender: Any? = nil) {
        DispatchQueue.global().async {
            let data = (try? Keychain(service: "com.v2ex.www").getData("session")) ?? .init()
            DispatchQueue.main.async {
                let signInController = SignInController()
                signInController.session = try? Session(data: data)
                let navigationController = UINavigationController(rootViewController: signInController)
                navigationController.modalPresentationStyle = sender is UIBarButtonItem ? .popover : .formSheet
                navigationController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                self.present(navigationController, animated: true)
            }
        }
    }
}

extension TopicsController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [
            topics.count,
            node.code == Node.all.code && user?.once == nil && topics.count > 0 ? 1 : 0,
        ][section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: TopicsCell.description(), for: indexPath) as? TopicsCell ?? .init()
            cell.tableViewStyle = tableView.style
            cell.topic = topics[indexPath.row]
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
            cell.textLabel?.text = "登录后查看更多"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = tableView.tintColor
            return cell

        default:
            return .init()
        }
    }
}

extension TopicsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !topicsIsLoaded && indexPath.row == topics.count - 1 { fetchData() }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let topicController = TopicController()
            topicController.topic = topics[indexPath.row]
            navigationController?.pushViewController(topicController, animated: true)

        case 1:
            tableView.deselectRow(at: indexPath, animated: true)
            showSignIn()

        default:
            break
        }
    }
}
