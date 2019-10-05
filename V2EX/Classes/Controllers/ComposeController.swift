//
//  ComposeController.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 6/8/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Alamofire

class ComposeController: ViewController {

    public  var reply: Reply?
    private var textView: UITextView!
    public  var topic: Topic?

    override init() {
        super.init()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "放弃", style: .plain, target: self, action: #selector(discard))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem?.isEnabled = false

        title = "回复"
    }

    override func loadView() {
        textView = UITextView()
        textView.alwaysBounceVertical = true
        textView.contentInset = UIEdgeInsets(top: 3, left: 15, bottom: 3, right: 15)
        textView.delegate = self
        textView.font = .preferredFont(forTextStyle: .body)
        textView.text = reply != nil ? "@\(reply?.user?.name ?? "") " : nil
        view = textView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textView.becomeFirstResponder()
    }

    @objc
    private func discard() {
        view.endEditing(true)
        if textView.text == "" { return dismiss(animated: true) }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "放弃", style: .destructive) { _ in
            self.dismiss(animated: true)
        })
        alertController.addAction(UIAlertAction(title: "继续", style: .cancel))
        present(alertController, animated: true)
    }

    @objc
    private func done() {
        view.endEditing(true)
        showHUD()
        let url = baseURL
            .appendingPathComponent("t")
            .appendingPathComponent(String(topic?.id ?? 0))
        AF.request(
            url,
            method: .post,
            parameters: [
                "content": textView.text ?? "",
                "once": topic?.once ?? "",
            ],
            headers: [
                "Referer": url.absoluteString,
            ]
        )
        .responseString { response in
            if 200..<300 ~= response.response?.statusCode ?? 0 {
                let alertController = UIAlertController(title: "已回复", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "好", style: .default) { _ in
                    self.dismiss(animated: true)
                })
                self.present(alertController, animated: true)
            } else {
                self.networkError()
            }
            self.hideHUD()
        }
    }
}

extension ComposeController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        navigationItem.rightBarButtonItem?.isEnabled = textView.text != ""
    }
}
