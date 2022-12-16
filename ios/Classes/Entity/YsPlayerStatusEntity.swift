//
//  YsPlayerStatusEntity.swift
//  app_settings
//
//  Created by 潇洒的然然 on 2022/12/15.
//

import Foundation

class YsPlayerStatusEntity:Codable {
    var isSuccess:Bool?
    var playErrorInfo:String?
    var talkErrorInfo:String?
    
    init(isSuccess: Bool? = nil, playErrorInfo: String? = nil, talkErrorInfo: String? = nil) {
        self.isSuccess = isSuccess
        self.playErrorInfo = playErrorInfo
        self.talkErrorInfo = talkErrorInfo
    }
    
    func getString() -> String {
        let data = try? JSONEncoder().encode(self)
        guard let jsonData = data else {return ""}
        guard let jsonStr = String.init(data: jsonData, encoding: .utf8) else {return ""}
        return jsonStr
    }
}


