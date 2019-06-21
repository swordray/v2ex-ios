//
//  SignInCaptchaCell.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/17/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class SignInCaptchaCell: UITableViewCell {

    public  var captchaField: UITextField!
    public  var captchaImageView: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        textLabel?.text = " "

        let stackView = UIStackView()
        stackView.spacing = 15
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalTo(textLabel ?? .init()) }

        captchaField = UITextField()
        captchaField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        captchaField.autocapitalizationType = .none
        captchaField.autocorrectionType = .no
        captchaField.clearButtonMode = .whileEditing
        captchaField.delegate = self
        captchaField.font = .preferredFont(forTextStyle: .body)
        captchaField.placeholder = "验证码"
        captchaField.returnKeyType = .join
        stackView.addArrangedSubview(captchaField)

        captchaImageView = UIImageView()
        captchaImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fetchData)))
        captchaImageView.isUserInteractionEnabled = true
        captchaImageView.snp.makeConstraints { $0.width.equalTo(captchaImageView.snp.height).multipliedBy(176 / 44.0) }
        stackView.addArrangedSubview(captchaImageView)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        (viewController as? SignInController)?.session?.captcha = textField.text
    }

    @objc
    private func fetchData() {
        (viewController as? SignInController)?.fetchData()
    }
}

extension SignInCaptchaCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        (viewController as? SignInController)?.signIn()
        return false
    }
}
