//
//  Node.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/8/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Ladybug

struct Node: JSONCodable {

    var name: String?
    var code: String?

    static var all = Node(name: "全部", code: "all")
}
