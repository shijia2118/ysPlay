//
//  EZUIPlayerViewFactory.swift
//  Runner
//
//  Created by py on 2021/8/21.
//

import Foundation
import Flutter
import UIKit

class EZUIPlayerViewFactory: NSObject, FlutterPlatformViewFactory {

    private var messenger: FlutterBinaryMessenger

    init (messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return EZUIPlayerView(frame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
    }

}

