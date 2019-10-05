//
//  Section.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/19/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Ladybug

struct Section: JSONCodable {

    var name: String?
    var nodes: [Node]
}
