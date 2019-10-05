//
//  TopicCommentCell.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/19/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class TopicCommentCell: TopicWebCell {

    public  var comment: Comment? { didSet { didSetComment() } }
    private var createdAtLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { $0.margins.equalToSuperview().priority(999) }

        createdAtLabel = UILabel()
        createdAtLabel.font = .preferredFont(forTextStyle: .subheadline)
        createdAtLabel.numberOfLines = 0
        createdAtLabel.textColor = .secondaryLabel
        stackView.addArrangedSubview(createdAtLabel)

        stackView.addArrangedSubview(webView)
    }

    private func didSetComment() {
        bodyHTML = comment?.bodyHTML
        createdAtLabel.text = "第 \((comment?.index ?? 0) + 1) 条附言 · \(comment?.createdAt ?? "")"
    }
}
