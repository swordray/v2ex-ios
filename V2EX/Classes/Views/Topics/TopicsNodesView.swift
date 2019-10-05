//
//  TopicsNodesView.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/22/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class TopicsNodesView: UIScrollView {

    public  var isEnabled = true { didSet { didSetEnabled() } }
    public  var nodes: [Node]? { didSet { didSetNodes() } }
    private var stackView: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        alwaysBounceHorizontal = true

        showsHorizontalScrollIndicator = false

        stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = 8
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.leading.trailing.centerY.equalToSuperview() }

        let topicsNodeButton = TopicsNodeButton()
        topicsNodeButton.isSelected = true
        topicsNodeButton.node = .all
        stackView.addArrangedSubview(topicsNodeButton)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func didSetEnabled() {
        stackView.arrangedSubviews.forEach { ($0 as? TopicsNodeButton)?.isEnabled = isEnabled }
    }

    private func didSetNodes() {
        nodes?.forEach { node in
            let topicsNodeButton = TopicsNodeButton()
            topicsNodeButton.node = node
            stackView.addArrangedSubview(topicsNodeButton)
        }
    }
}
