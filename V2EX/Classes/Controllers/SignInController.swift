//
//  SignInController.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/17/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Alamofire
import Kanna
import KeychainAccess

class SignInController: ViewController {

    private var activityIndicatorView: ActivityIndicatorView!
    private var isRefreshing = false { didSet { didSetRefreshing() } }
    private var networkErrorView: NetworkErrorView!
    public  var session: Session?
    private var tableView: UITableView!
    private var termsSwitch: UISwitch!

    override init() {
        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(action))

        title = "登录"
    }

    override func loadView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SignInCaptchaCell.self, forCellReuseIdentifier: SignInCaptchaCell.description())
        tableView.register(SignInPasswordCell.self, forCellReuseIdentifier: SignInPasswordCell.description())
        tableView.register(SignInUsernameCell.self, forCellReuseIdentifier: SignInUsernameCell.description())
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        view = tableView

        activityIndicatorView = ActivityIndicatorView()
        view.addSubview(activityIndicatorView)

        networkErrorView = NetworkErrorView()
        networkErrorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fetchData)))
        view.addSubview(networkErrorView)

        termsSwitch = UISwitch()
        termsSwitch.addTarget(tableView, action: #selector(tableView.reloadData), for: .valueChanged)
        termsSwitch.isOn = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: animated) }

        fetchData()
    }

    @objc
    internal func fetchData() {
        if isRefreshing { return }
        isRefreshing = true
        (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? SignInCaptchaCell)?.captchaField.text = nil
        AF.request(
            baseURL.appendingPathComponent("signin")
        ).responseString { response in
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let doc = try? HTML(html: response.value ?? "", encoding: .utf8)
                if let message = doc?.at_css(".topic_content p")?.text {
                    self.view.endEditing(true)
                    let alertController = UIAlertController(title: "登录受限", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "好", style: .default) { _ in
                        self.dismiss(animated: true)
                    })
                    self.present(alertController, animated: true)
                } else {
                    let json = [
                        "usernameKey": doc?.at_css("#Main form tr:nth-child(1) input")?["name"],
                        "passwordKey": doc?.at_css("#Main form tr:nth-child(2) input")?["name"],
                        "captchaKey": doc?.at_css("#Main form tr:nth-child(3) input")?["name"],
                        "once": "once=(\\d+)".r?.findFirst(in: doc?.at_css("#Main form tr:nth-child(3) td:nth-child(2) div[style]")?["style"] ?? "")?.group(at: 1),
                        "username": self.session?.username,
                        "password": self.session?.password,
                    ]
                    self.session = try? Session(json: json)
                    self.tableView.reloadSections([1], with: .none)
                }
            } else {
                self.networkErrorView.isHidden = false
            }
            self.isRefreshing = false
        }
    }

    private func didSetRefreshing() {
        if isRefreshing {
            networkErrorView.isHidden = true
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }

    @objc
    private func action() {
        view.endEditing(true)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        [("注册", "signup"), ("忘记密码", "forgot")].forEach { title, pathComponent in
            alertController.addAction(UIAlertAction(title: title, style: .default) { _ in
                let webViewController = WebViewController()
                webViewController.title = title
                webViewController.url = self.baseURL.appendingPathComponent(pathComponent)
                self.navigationController?.pushViewController(webViewController, animated: true)
            })
        }
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alertController, animated: true)
    }

    internal func signIn() {
        guard let session = session else { return }
        view.endEditing(true)
        showHUD()
        AF.request(
            baseURL.appendingPathComponent("signin"),
            method: .post,
            parameters: [
                session.usernameKey: session.username ?? "",
                session.passwordKey: session.password ?? "",
                session.captchaKey: session.captcha ?? "",
                "once": session.once,
                "next": "/",
            ],
            headers: [
                "Referer": baseURL.appendingPathComponent("signin").absoluteString,
            ]
        )
        .responseString { response in
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let doc = try? HTML(html: response.value ?? "", encoding: .utf8)
                if let title = doc?.at_css(".problem ul li")?.text {
                    self.fetchData()
                    let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "好", style: .default))
                    self.present(alertController, animated: true)
                } else {
                    DispatchQueue.global().async {
                        let session = Session(usernameKey: "", passwordKey: "", captchaKey: "", once: "", username: session.username, password: session.password, captcha: nil)
                        try? Keychain(service: "com.v2ex.www").accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence).set(session.toData(), key: "session")
                        DispatchQueue.main.async {
                            (((self.presentingViewController as? UITabBarController)?.viewControllers?.first as? UINavigationController)?.viewControllers.first as? TopicsController)?.signed()
                            self.dismiss(animated: true)
                        }
                    }
                }
            } else {
                self.networkError()
            }
            self.hideHUD()
        }
    }
}

extension SignInController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [2, 1, 1, 1][section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: SignInUsernameCell.description(), for: indexPath) as? SignInUsernameCell ?? .init()
            cell.usernameField.text = session?.username
            return cell

        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: SignInPasswordCell.description(), for: indexPath) as? SignInPasswordCell ?? .init()
            cell.passwordField.text = session?.password
            return cell

        case (1, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: SignInCaptchaCell.description(), for: indexPath) as? SignInCaptchaCell ?? .init()
            cell.captchaField.text = session?.captcha
            if let once = session?.once {
                let url = URL(string: "\(baseURL.absoluteString)/_captcha?once=\(once)")
                cell.captchaImageView.setImage(withURL: url)
            }
            return cell

        case (2, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
            cell.accessoryView = termsSwitch
            cell.backgroundColor = .clear
            cell.textLabel?.text = "同意最终用户许可协议"
            cell.textLabel?.textColor = tableView.tintColor
            return cell

        case (3, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
            cell.selectionStyle = termsSwitch.isOn ? .default : .none
            cell.textLabel?.text = "登录"
            cell.textLabel?.textColor = termsSwitch.isOn ? tableView.tintColor : .tertiaryLabel
            return cell

        default:
            return .init()
        }
    }
}

extension SignInController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (2, 0):
            let webViewController = WebViewController()
            webViewController.title = "最终用户许可协议"
            webViewController.url = baseURL.appendingPathComponent("about")
            navigationController?.pushViewController(webViewController, animated: true)

        case (3, 0):
            tableView.deselectRow(at: indexPath, animated: true)
            if termsSwitch.isOn { signIn() }

        default:
            break
        }
    }
}
