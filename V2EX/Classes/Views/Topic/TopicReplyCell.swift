//
//  TopicReplyCell.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/10/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class TopicReplyCell: TopicWebCell {

    private var createdAtLabel: UILabel!
    private var indexButton: UIButton!
    public  var reply: Reply? { didSet { didSetReply() } }
    private var userAvatarView: UIImageView!
    private var userNameButton: UIButton!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let size = CGSize(width: UIFontMetrics.default.scaledValue(for: 44), height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView?.image = image

        userAvatarView = UIImageView()
        userAvatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUser)))
        userAvatarView.backgroundColor = .groupTableViewBackground
        userAvatarView.clipsToBounds = true
        userAvatarView.isUserInteractionEnabled = true
        userAvatarView.layer.cornerRadius = UIFontMetrics.default.scaledValue(for: 22)
        contentView.addSubview(userAvatarView)
        userAvatarView.snp.makeConstraints { make in
            make.leading.top.equalTo(contentView.layoutMarginsGuide)
            make.bottom.lessThanOrEqualTo(contentView.layoutMarginsGuide).priority(999)
            make.size.equalTo(UIFontMetrics.default.scaledValue(for: 44))
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = UIFontMetrics.default.scaledValue(for: 8)
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.trailing.top.equalTo(contentView.layoutMarginsGuide)
            make.bottom.lessThanOrEqualTo(contentView.layoutMarginsGuide)
            make.leading.equalTo(userAvatarView.snp.trailing).offset(15)
        }

        let detailStackView = UIStackView()
        detailStackView.spacing = UIFontMetrics.default.scaledValue(for: 8)
        stackView.addArrangedSubview(detailStackView)

        userNameButton = UIButton()
        userNameButton.addTarget(self, action: #selector(showUser), for: .touchUpInside)
        userNameButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .leastNormalMagnitude)
        userNameButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        userNameButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        userNameButton.setTitleColor(tintColor, for: .normal)
        userNameButton.setTitleColor(tintColor.withAlphaComponent(0.2), for: .highlighted)
        userNameButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        detailStackView.addArrangedSubview(userNameButton)

        createdAtLabel = UILabel()
        createdAtLabel.font = .preferredFont(forTextStyle: .subheadline)
        createdAtLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        createdAtLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        createdAtLabel.textColor = .lightGray
        detailStackView.addArrangedSubview(createdAtLabel)

        indexButton = UIButton()
        indexButton.addTarget(self, action: #selector(showActions), for: .touchUpInside)
        indexButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .leastNormalMagnitude)
        indexButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        indexButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        indexButton.setTitleColor(tintColor, for: .normal)
        indexButton.setTitleColor(tintColor.withAlphaComponent(0.2), for: .highlighted)
        indexButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        detailStackView.addArrangedSubview(indexButton)

        stackView.addArrangedSubview(webView)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        userNameButton.setTitleColor(tintColor, for: .normal)
        indexButton.setTitleColor(tintColor, for: .normal)
    }

    private func didSetReply() {
        bodyHTML = reply?.bodyHTML
        createdAtLabel.text = reply?.createdAt
        indexButton.setTitle("#\((reply?.index ?? 0) + 1)", for: .normal)
        userAvatarView.setImage(withURL: reply?.user?.avatar)
        userNameButton.setTitle(reply?.user?.name, for: .normal)
    }

    @objc
    private func showUser() {
        let userController = UserController()
        userController.user = reply?.user
        viewController?.navigationController?.pushViewController(userController, animated: true)
    }

    @objc
    private func showActions(_ button: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "回复", style: .default) { _ in
            (self.viewController as? TopicController)?.showCompose(button, self.reply)
        })
        alertController.addAction(UIAlertAction(title: "举报", style: .destructive) { _ in
            (self.viewController as? TopicController)?.report()
        })
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        alertController.popoverPresentationController?.sourceRect = button.bounds
        alertController.popoverPresentationController?.sourceView = button
        viewController?.present(alertController, animated: true)
    }
}
