//
//  UserHeaderView.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/16/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class UserHeaderView: UITableViewHeaderFooterView {

    private var avatarView: UIImageView!
    private var createdAtLabel: UILabel!
    private var idLabel: UILabel!
    private var nameLabel: UILabel!
    public  var user: User? { didSet { didSetUser() } }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = UIFontMetrics.default.scaledValue(for: 12)
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leadingMargin.trailingMargin.equalToSuperview()
            make.top.equalToSuperview().offset(UIFontMetrics.default.scaledValue(for: 20))
            make.bottom.equalToSuperview().offset(UIFontMetrics.default.scaledValue(for: -20)).priority(999)
        }

        avatarView = UIImageView()
        avatarView.backgroundColor = .white
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = UIFontMetrics.default.scaledValue(for: 44)
        avatarView.snp.makeConstraints { $0.size.equalTo(UIFontMetrics.default.scaledValue(for: 88)) }
        stackView.addArrangedSubview(avatarView)

        nameLabel = UILabel()
        nameLabel.font = .preferredFont(forTextStyle: .title1)
        stackView.addArrangedSubview(nameLabel)

        idLabel = UILabel()
        idLabel.font = .preferredFont(forTextStyle: .body)
        stackView.addArrangedSubview(idLabel)

        createdAtLabel = UILabel()
        createdAtLabel.font = .preferredFont(forTextStyle: .body)
        createdAtLabel.textColor = .gray
        stackView.addArrangedSubview(createdAtLabel)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func didSetUser() {
        avatarView.setImage(withURL: user?.avatar)
        createdAtLabel.text = user?.createdAt != nil ? "加入于\(user?.createdAt?.toRelative() ?? "")" : nil
        idLabel.text = user?.id != nil ? "第 \(user?.id ?? 0) 号会员" : nil
        nameLabel.text = user?.name
    }
}
