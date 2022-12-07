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

    private var messenger:FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return YsPlayView(binaryMessenger: messenger)
    }

}

