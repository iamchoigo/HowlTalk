//
//  UserModel.swift
//  HowlTalk
//
//  Created by 최고은 on 2019/11/17.
//  Copyright © 2019 goeun choi. All rights reserved.
//

import ObjectMapper

struct UserModel: Mappable{
    var userName : String?
    var uid : String?
    var profileImageUrl : String?
    var userEmail : String?
    var userPassword : String?

    init() {
        
    }
    init?(map: Map) {
           
    }
    mutating func mapping(map: Map) {
        userName <- map["userName"]
        uid <- map["uid"]
        profileImageUrl <- map["profileImageUrl"]
        userEmail <- map["userEmail"]
        userPassword <- map["userPassword"]
    }
}
