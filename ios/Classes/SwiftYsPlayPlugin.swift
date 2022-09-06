//
//  SwiftYsPlayPlugin.swift
//  ys_play
//
//  Created by UI Seeyou on 2022/9/6.
//

import Flutter
import UIKit
import EZOpenSDKFramework

public class SwiftYsPlayPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {

  let factory = EZUIPlayerViewFactory(messenger: registrar.messenger())
  registrar.register(factory, withId: "com.example.ys_play")

    let channel = FlutterMethodChannel(name: "com.example.ys_play", binaryMessenger: registrar.messenger())
    let instance = SwiftYsPlayPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//     result("iOS " + UIDevice.current.systemVersion)
    if call.method == "init_sdk" {
        let data:Optional<Dictionary> = call.arguments as! Dictionary<String, String>

        result(EZOpenSDK.initLib(withAppKey: data?["appKey"]))
    } else if call.method == "set_access_token" {
        let data:Optional<Dictionary> = call.arguments as! Dictionary<String, String>
        EZOpenSDK.setAccessToken(data?["accessToken"] as! String)
        result("success")
    } else if call.method == "destoryLib" {
        EZOpenSDK.destoryLib()
        result("success")
    } else {
        result(FlutterMethodNotImplemented)
    }

  }
}

