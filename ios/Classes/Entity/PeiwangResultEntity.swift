//
//  YsPlayerStatusEntity.swift
//  app_settings
//
//  Created by 潇洒的然然 on 2022/12/15.
//

import Foundation

class PeiwangResultEntity:Codable {
    var isSuccess:Bool?
    var msg:String?
    
    init(isSuccess: Bool? = nil, msg: String? = nil) {
        self.isSuccess = isSuccess
        self.msg = msg
    }
    
    func getString() -> String {
        let data = try? JSONEncoder().encode(self)
        guard let jsonData = data else {return ""}
        guard let jsonStr = String.init(data: jsonData, encoding: .utf8) else {return ""}
        return jsonStr
    }
}


