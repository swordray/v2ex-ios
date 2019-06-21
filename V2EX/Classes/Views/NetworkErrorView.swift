//
//  NetworkErrorView.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/11/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

class NetworkErrorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        isHidden = true

        let label = UILabel()
        label.backgroundColor = .gray
        label.clipsToBounds = true
        label.font = .boldSystemFont(ofSize: 17)
        label.layer.cornerRadius = 10
        label.text = "!"
        label.textAlignment = .center
        label.textColor = .white
        addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let superview = superview {
            snp.makeConstraints { $0.edges.equalTo(superview.safeAreaLayoutGuide) }
        }
    }
}
