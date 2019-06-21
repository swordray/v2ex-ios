//
//  Comment.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/17/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Ladybug

struct Comment: JSONCodable {

    var bodyHTML: String?
    var createdAt: String?
    var index: Int?
}
