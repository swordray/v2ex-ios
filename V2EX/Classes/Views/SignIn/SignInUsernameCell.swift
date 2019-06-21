//
//  SignInUsernameCell.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/22/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class SignInUsernameCell: UITableViewCell {

    public  var usernameField: UITextField!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        textLabel?.text = " "

        usernameField = UITextField()
        usernameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.clearButtonMode = .whileEditing
        usernameField.delegate = self
        usernameField.font = .preferredFont(forTextStyle: .body)
        usernameField.placeholder = "帐号"
        usernameField.returnKeyType = .next
        usernameField.textContentType = .username
        contentView.addSubview(usernameField)
        usernameField.snp.makeConstraints { $0.edges.equalTo(textLabel ?? .init()) }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        (viewController as? SignInController)?.session?.username = textField.text
    }
}

extension SignInUsernameCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        (next(of: UITableView.self)?.cellForRow(at: IndexPath(row: 1, section: 0)) as? SignInPasswordCell)?.passwordField.becomeFirstResponder()
        return false
    }
}
