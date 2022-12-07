//
//  YsPlayViewFactory.swift
//  Runner
//
//  Created by 潇洒的然然 on 2022/11/30.
//

import Foundation
import Flutter
import UIKit

class YsPlayViewFactory: NSObject, FlutterPlatformViewFactory {
//    var callback: ((_ tmpView:UIView)->())?
//    var playerView:UIView?
    
//    override init(){
//        if playerView != nil {
//            if let block = callback{
//                print(">>>>>>>>>view1==\(playerView)")
//                block(playerView!)
//            }
//        }
//    }
    
    private var messenger:FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    
   
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
//        let ysPlayView = YsPlayView()
//        ysPlayView.callback = callback
//        ysPlayView.callback = {[weak self] (tmpView:UIView) in
//            self?.playerView = tmpView
//            print(">>>>>>>>view2==\(tmpView)")
//        }
//
        return YsPlayView(binaryMessenger: messenger)
    }
    
   

}

