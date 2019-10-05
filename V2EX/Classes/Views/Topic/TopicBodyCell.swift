//
//  BodyCell.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/10/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class TopicBodyCell: TopicWebCell {

    public  var topic: Topic? { didSet { didSetTopic() } }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalTo(contentView.layoutMarginsGuide).priority(999) }
    }

    private func didSetTopic() {
        bodyHTML = topic?.bodyHTML
    }
}
