//
//  Reply.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/10/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Ladybug

struct Reply: JSONCodable {

    var bodyHTML: String?
    var createdAt: String?
    var user: User?
    var index: Int?
}
