//
//  Session.swift
//  V2EX
//
//  Created by Jianqiu Xiao on 4/17/19.
//  Copyright © 2019 Jianqiu Xiao. All rights reserved.
//

import Ladybug

struct Session: JSONCodable {

    var usernameKey: String
    var passwordKey: String
    var captchaKey: String
    var once: String
    var username: String?
    var password: String?
    var captcha: String?
}
