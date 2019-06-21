//
//  WebViewController.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/11/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import JXWebViewController
import TUSafariActivity
import WebKit

class WebViewController: JXWebViewController {

    private var activityIndicatorView: ActivityIndicatorView!
    private var isRefreshing = false { didSet { didSetRefreshing() } }
    private var networkErrorView: NetworkErrorView!
    public  var url: URL?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(action))
    }

    override func loadView() {
        super.loadView()

        view.backgroundColor = .white

        if title != nil {
            webViewKeyValueObservations[\WKWebView.title] = nil
        }

        activityIndicatorView = ActivityIndicatorView()
        view.addSubview(activityIndicatorView)

        networkErrorView = NetworkErrorView()
        networkErrorView.addGestureRecognizer(UITapGestureRecognizer(target: webView, action: #selector(webView.reload)))
        view.addSubview(networkErrorView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if webView.url == nil, let url = url {
            webView.load(URLRequest(url: url))
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
    private func action(_ barButtonItem: UIBarButtonItem) {
        guard let url = webView.url else { return }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [TUSafariActivity()])
        activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        present(activityViewController, animated: true)
    }
}

extension WebViewController {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isRefreshing = true
    }

    override func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        super.webView(webView, didFailProvisionalNavigation: navigation, withError: error)

        isRefreshing = false
        networkErrorView.isHidden = false
    }

    override func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        super.webView(webView, didFail: navigation, withError: error)

        isRefreshing = false
        networkErrorView.isHidden = false
    }

    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)

        isRefreshing = false
    }
}
