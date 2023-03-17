//
//  EZPlayerView.swift
//  Runner
//
//  Created by 潇洒的然然 on 2022/12/01.
//

import Foundation
import Flutter
import UIKit

class YsPlayView: NSObject, FlutterPlatformView{
   
    func view() -> UIView {
        // 实例化播放视图
        let uiView = UIView()
        
        // 发送通知，把uiview传给 [SwiftYsPlayPlugin]
        let notification = Notification(name: Notification.Name.init("video_view"),object: uiView)
        NotificationCenter.default.post(notification)
        return uiView
    }
    
   
    
    

    
        
    
    
   

    
    
}
