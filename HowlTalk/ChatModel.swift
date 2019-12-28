//
//  ChatModel.swift
//  HowlTalk
//
//  Created by 최고은 on 2019/11/24.
//  Copyright © 2019 goeun choi. All rights reserved.
//

import ObjectMapper

struct ChatModel : Mappable{
    var comments : [String : Comment] = [:]
    var users : [String : Bool] = [:]

    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        comments <- map["comments"]
        users <- map["users"]
    }
        
    struct Comment : Mappable{
        var uid : String?
        var message : String?
        var timestamp : Int?
        
        init?(map: Map) {
            
        }
        
        mutating func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timestamp <- map["timestamp"]
        }
    }
}
