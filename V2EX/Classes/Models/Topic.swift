//
//  Topic.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/8/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Ladybug

struct Topic: JSONCodable {

    var id: Int?
    var name: String?
    var bodyHTML: String?
    var clicksCount: Int?
    var favoritesCount: Int?
    var repliesCount: Int?
    var repliesNextPage: Int?
    var repliedAt: String?
    var createdAt: String?
    var isSticky: Bool?
    var isFavorite: Bool?
    var favoriteToken: String?
    var once: Int?
    var user: User?
    var node: Node?
    var comments: [Comment]?
}
