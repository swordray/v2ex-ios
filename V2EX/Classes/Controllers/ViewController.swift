//
//  ViewController.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/8/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import JGProgressHUD

class ViewController: UIViewController {

    private var progressHUD: JGProgressHUD?

    init() {
        super.init(nibName: nil, bundle: nil)

        userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userActivity?.becomeCurrent()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        userActivity?.invalidate()
    }

    internal var baseURL: URL {
        return URL(string: "https://www.v2ex.com") ?? .init(fileURLWithPath: "")
    }

    @objc
    internal func dismiss(_ sender: Any? = nil) {
        view.endEditing(true)
        dismiss(animated: true)
    }

    internal func hideHUD() {
        progressHUD?.dismiss(animated: false)
    }

    internal func networkError() {
        let alertController = UIAlertController(title: "网络错误", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "好", style: .default))
        present(alertController, animated: true)
    }

    internal func showHUD() {
        var ancestor: UIViewController = self
        while let parent = ancestor.parent { ancestor = parent }
        progressHUD = progressHUD ?? JGProgressHUD(style: .extraLight)
        progressHUD?.show(in: ancestor.view, animated: false)
    }

    internal func signInRequired(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "登录", style: .default) { _ in
            let tabBarController = self.tabBarController
            self.navigationController?.popToRootViewController(animated: false)
            tabBarController?.selectedIndex = 0
            let navigationController = tabBarController?.selectedViewController as? UINavigationController
            navigationController?.popToRootViewController(animated: false)
            (navigationController?.viewControllers.first as? TopicsController)?.showSignIn()
        })
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        alertController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        alertController.popoverPresentationController?.sourceRect = (sender as? UIView)?.bounds ?? .zero
        alertController.popoverPresentationController?.sourceView = sender as? UIView
        present(alertController, animated: true)
    }
}
