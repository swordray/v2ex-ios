//
//  UIView.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/10/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import UIKit

extension UIResponder {

    internal func next<T>(of type: T.Type) -> T? {
        return next as? T ?? next?.next(of: type)
    }
}

extension UIView {

    internal var viewController: ViewController? {
        return next(of: ViewController.self)
    }
}
