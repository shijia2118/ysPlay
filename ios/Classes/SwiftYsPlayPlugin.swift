//
//  SwiftYsPlayPlugin.swift
//  ys_play
//
//  Created by 潇洒的然然 on 2022/9/6.
//ra.835vtvy52xjef2xu4ex411xh0b58jzs6-8dw4c3i6jv-1ear9lx-4zzpegyxv

import Flutter
import UIKit
import EZOpenSDKFramework

public class SwiftYsPlayPlugin: NSObject, FlutterPlugin,EZPlayerDelegate{
    
    var ezPlayer:EZPlayer
    var playerView:UIView?
    let TAG = "荧石SDK=======>"
    
    init(messenger:FlutterBinaryMessenger){
      ezPlayer = EZOpenSDK.createPlayer(withDeviceSerial: "123", cameraNo: 1)
      super.init()
      ezPlayer.destoryPlayer()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = YsPlayViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: Constants.CHANNEL)
        let channel = FlutterMethodChannel(name: Constants.CHANNEL, binaryMessenger: registrar.messenger())
        let instance = SwiftYsPlayPlugin(messenger: registrar.messenger() )
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "init_sdk" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, String>
            if data == nil || data!["appKey"] == nil {
                result(false)
            }else{
                let res:Bool = EZOpenSDK.initLib(withAppKey: data!["appKey"]!)
                print("\(TAG) SDK初始化 \(res ? "成功" : "失败")")
                result(res)
            }
        }else if call.method == "set_access_token" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, String>
            EZOpenSDK.setAccessToken(data?["accessToken"] as? String)
            print("\(TAG)accessToken设置成功")
            result(true)
        }else if call.method == "destoryLib" {
            let isSuccess = EZOpenSDK.destoryLib()
            print("\(TAG) SDK销毁 \(isSuccess ? "成功" : "失败")")
            result(true)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    

}

