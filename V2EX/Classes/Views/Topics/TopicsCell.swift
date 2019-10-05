//
//  Cell.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/8/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class TopicsCell: UITableViewCell {

    private var nameLabel: UILabel!
    private var nodeButton: UIButton!
    private var repliedAtLabel: UILabel!
    private var repliesCountLabel: UILabel!
    public  var tableViewStyle: UITableView.Style?
    public  var topic: Topic? { didSet { didSetTopic() } }
    private var userAvatarView: UIImageView!
    private var userNameLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator

        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = 8
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { $0.margins.equalToSuperview().priority(999) }

        userAvatarView = UIImageView()
        userAvatarView.backgroundColor = .secondarySystemBackground
        userAvatarView.clipsToBounds = true
        userAvatarView.layer.cornerRadius = 22
        userAvatarView.snp.makeConstraints { $0.size.equalTo(44) }
        stackView.addArrangedSubview(userAvatarView)
        stackView.setCustomSpacing(15, after: userAvatarView)

        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 8
        contentStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(contentStackView)

        nameLabel = UILabel()
        nameLabel.font = .preferredFont(forTextStyle: .body)
        nameLabel.numberOfLines = 3
        contentStackView.addArrangedSubview(nameLabel)

        let detailStackView = UIStackView()
        detailStackView.spacing = 8
        contentStackView.addArrangedSubview(detailStackView)

        nodeButton = UIButton()
        nodeButton.backgroundColor = .quaternarySystemFill
        nodeButton.clipsToBounds = true
        nodeButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        nodeButton.isUserInteractionEnabled = false
        nodeButton.layer.cornerRadius = 3
        nodeButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        nodeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nodeButton.setTitleColor(.secondaryLabel, for: .normal)
        nodeButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        detailStackView.addArrangedSubview(nodeButton)

        userNameLabel = UILabel()
        userNameLabel.font = .preferredFont(forTextStyle: .subheadline)
        userNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        userNameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        userNameLabel.textColor = .secondaryLabel
        detailStackView.addArrangedSubview(userNameLabel)

        repliedAtLabel = UILabel()
        repliedAtLabel.font = .preferredFont(forTextStyle: .subheadline)
        repliedAtLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        repliedAtLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        repliedAtLabel.textColor = .tertiaryLabel
        detailStackView.addArrangedSubview(repliedAtLabel)

        repliesCountLabel = UILabel()
        repliesCountLabel.font = .preferredFont(forTextStyle: .body)
        repliesCountLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        repliesCountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        repliesCountLabel.textColor = .secondaryLabel
        stackView.addArrangedSubview(repliesCountLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func didSetTopic() {
        backgroundColor = topic?.isSticky ?? false ? .secondarySystemBackground : tableViewStyle == .plain ? .systemBackground : .secondarySystemGroupedBackground
        nameLabel.text = topic?.name
        nodeButton.isHidden = topic?.node?.name == nil
        nodeButton.setTitle(topic?.node?.name, for: .normal)
        repliedAtLabel.text = topic?.repliedAt
        repliesCountLabel.text = String(topic?.repliesCount ?? 0)
        userAvatarView.isHidden = topic?.user == nil
        userAvatarView.setImage(withURL: topic?.user?.avatar)
        userNameLabel.isHidden = topic?.user == nil
        userNameLabel.text = topic?.user?.name

        if topic?.user != nil {
            let size = CGSize(width: 44, height: 1)
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imageView?.image = image
        }
    }
}
