//
//  NameCell.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/9/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class TopicNameCell: UITableViewCell {

    private var createdAtLabel: UILabel!
    private var nameLabel: UILabel!
    private var nodeButton: UIButton!
    public  var topic: Topic? { didSet { didSetTopic() } }
    private var userAvatarView: UIImageView!
    private var userNameButton: UIButton!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = UIFontMetrics.default.scaledValue(for: 8)
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { $0.margins.equalToSuperview().priority(999) }

        nameLabel = UILabel()
        nameLabel.font = .preferredFont(forTextStyle: .title2)
        nameLabel.numberOfLines = 0
        stackView.addArrangedSubview(nameLabel)

        let detailStackView = UIStackView()
        detailStackView.alignment = .center
        detailStackView.spacing = UIFontMetrics.default.scaledValue(for: 8)
        stackView.addArrangedSubview(detailStackView)

        userAvatarView = UIImageView()
        userAvatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUser)))
        userAvatarView.backgroundColor = .groupTableViewBackground
        userAvatarView.clipsToBounds = true
        userAvatarView.isUserInteractionEnabled = true
        userAvatarView.layer.cornerRadius = UIFontMetrics.default.scaledValue(for: 22)
        userAvatarView.snp.makeConstraints { $0.size.equalTo(UIFontMetrics.default.scaledValue(for: 44)) }
        detailStackView.addArrangedSubview(userAvatarView)
        detailStackView.setCustomSpacing(UIFontMetrics.default.scaledValue(for: 15), after: userAvatarView)

        userNameButton = UIButton()
        userNameButton.addTarget(self, action: #selector(showUser), for: .touchUpInside)
        userNameButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .leastNormalMagnitude)
        userNameButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        userNameButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        userNameButton.setTitleColor(tintColor, for: .normal)
        userNameButton.setTitleColor(tintColor.withAlphaComponent(0.2), for: .highlighted)
        userNameButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        detailStackView.addArrangedSubview(userNameButton)

        let flexibleSpaceView = UIView()
        detailStackView.addArrangedSubview(flexibleSpaceView)
        detailStackView.setCustomSpacing(0, after: flexibleSpaceView)

        nodeButton = UIButton()
        nodeButton.addTarget(self, action: #selector(showNode), for: .touchUpInside)
        nodeButton.backgroundColor = .groupTableViewBackground
        nodeButton.clipsToBounds = true
        nodeButton.contentEdgeInsets = UIEdgeInsets(top: UIFontMetrics.default.scaledValue(for: 3), left: UIFontMetrics.default.scaledValue(for: 3), bottom: UIFontMetrics.default.scaledValue(for: 3), right: UIFontMetrics.default.scaledValue(for: 3))
        nodeButton.layer.cornerRadius = UIFontMetrics.default.scaledValue(for: 3)
        nodeButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        nodeButton.setTitleColor(tintColor, for: .normal)
        nodeButton.setTitleColor(tintColor.withAlphaComponent(0.2), for: .highlighted)
        detailStackView.addArrangedSubview(nodeButton)

        createdAtLabel = UILabel()
        createdAtLabel.font = .preferredFont(forTextStyle: .subheadline)
        createdAtLabel.numberOfLines = 0
        createdAtLabel.textColor = .lightGray
        stackView.addArrangedSubview(createdAtLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        userNameButton.setTitleColor(tintColor, for: .normal)
        nodeButton.setTitleColor(tintColor, for: .normal)
    }

    private func didSetTopic() {
        createdAtLabel.text = [
            topic?.createdAt,
            topic?.clicksCount != nil ? "\(topic?.clicksCount ?? 0) 次点击" : nil,
            topic?.favoritesCount != nil ? "\(topic?.favoritesCount ?? 0) 人收藏" : nil,
        ].compactMap { $0 }.joined(separator: " · ") + " "
        nameLabel.text = topic?.name ?? " "
        nodeButton.isHidden = topic?.node?.name == nil
        nodeButton.setTitle(topic?.node?.name, for: .normal)
        userAvatarView.setImage(withURL: topic?.user?.avatar)
        userNameButton.setTitle(topic?.user?.name, for: .normal)
    }

    @objc
    private func showUser() {
        guard let user = topic?.user else { return }
        let userController = UserController()
        userController.user = user
        viewController?.navigationController?.pushViewController(userController, animated: true)
    }

    @objc
    private func showNode() {
        guard let node = topic?.node else { return }
        let topicsController = TopicsController()
        topicsController.node = node
        viewController?.navigationController?.pushViewController(topicsController, animated: true)
    }
}
