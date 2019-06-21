//
//  SignInPasswordCell.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/22/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class SignInPasswordCell: UITableViewCell {

    public  var passwordField: UITextField!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        textLabel?.text = " "

        passwordField = UITextField()
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordField.clearButtonMode = .whileEditing
        passwordField.delegate = self
        passwordField.font = .preferredFont(forTextStyle: .body)
        passwordField.isSecureTextEntry = true
        passwordField.placeholder = "密码"
        passwordField.returnKeyType = .next
        passwordField.textContentType = .password
        contentView.addSubview(passwordField)
        passwordField.snp.makeConstraints { $0.edges.equalTo(textLabel ?? .init()) }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        (viewController as? SignInController)?.session?.password = textField.text
    }
}

extension SignInPasswordCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        (next(of: UITableView.self)?.cellForRow(at: IndexPath(row: 0, section: 1)) as? SignInCaptchaCell)?.captchaField.becomeFirstResponder()
        return false
    }
}
