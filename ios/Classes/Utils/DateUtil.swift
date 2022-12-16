//
//  DateUtil.swift
//  ys_play
//
//  Created by 潇洒的然然 on 2022/12/13.
//

import Foundation

class DateUtil {
    
    ///获取当前时间戳
    public static func getCurrentTimeStamp() -> Int {
        let now = Date()
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return timeStamp
    }
}
