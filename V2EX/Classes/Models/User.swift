//
//  User.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/8/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Ladybug

struct User: JSONCodable {

    var id: Int?
    var name: String?
    var avatar: URL?
    var isBlocked: Bool?
    var token: String?
    var once: String?
    var createdAt: Date?
    var topics: [Topic]?

    static let transformersByPropertyKey: [PropertyKey: JSONTransformer] = [
        "createdAt": "createdAt" <- format("yyyy-MM-dd HH:mm:ss ZZZZZ"),
    ]
}
