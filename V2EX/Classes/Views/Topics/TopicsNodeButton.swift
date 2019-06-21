//
//  TopicsNodeButton.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/22/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class TopicsNodeButton: UIButton {

    public  var node: Node! { didSet { didSetNode() } }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addTarget(self, action: #selector(selectNode), for: .touchUpInside)

        clipsToBounds = true

        contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)

        layer.cornerRadius = 5

        setBackgroundColor(.clear, for: .normal)

        setTitleColor(.white, for: .selected)
        setTitleColor(.white, for: [.selected, .highlighted])
        setTitleColor(.white, for: [.selected, .disabled])

        titleLabel?.font = .systemFont(ofSize: 15)

        tintColorDidChange()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        setBackgroundColor(tintColor, for: .selected)
        setBackgroundColor(tintColor, for: [.selected, .highlighted])
        setBackgroundColor(tintColor.withAlphaComponent(0.16), for: .highlighted)
        setBackgroundColor(tintColor.withAlphaComponent(0.5), for: [.selected, .disabled])

        setTitleColor(tintColor, for: .normal)
        setTitleColor(tintColor.withAlphaComponent(0.5), for: .disabled)
    }

    private func didSetNode() {
        setTitle(node.name, for: .normal)
    }

    @objc
    private func selectNode() {
        if isSelected { return }

        (superview as? UIStackView)?.arrangedSubviews.forEach { ($0 as? TopicsNodeButton)?.isSelected = $0 == self }

        (viewController as? TopicsController)?.node = node
    }
}
