//
//  SwiftYsPlayPlugin.swift
//  ys_play
//
//  Created by 潇洒的然然 on 2022/9/6.
//

import Flutter
import UIKit
import EZOpenSDKFramework

public class SwiftYsPlayPlugin: NSObject, FlutterPlugin,EZPlayerDelegate{
    
    private var ezPlayer:EZPlayer

    let TAG = "荧石SDK=======>"
    
    override init(){
        self.ezPlayer = EZOpenSDK.createPlayer(withDeviceSerial: "123", cameraNo: 1)
       
        super.init()
        self.ezPlayer.destoryPlayer()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
     
        let factory = YsPlayViewFactory()
       
        registrar.register(factory, withId: "com.example.ys_play")

        let channel = FlutterMethodChannel(name: "com.example.ys_play", binaryMessenger: registrar.messenger())
        let instance = SwiftYsPlayPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "init_sdk" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, String>
            if data == nil || data!["appKey"] == nil {
                result(false)
            }else{
                let res:Bool = EZOpenSDK.initLib(withAppKey: data!["appKey"]!)
                result(res)
            }
        } else if call.method == "set_access_token" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, String>
            EZOpenSDK.setAccessToken(data?["accessToken"] as? String)
            print("accessToken设置成功")
            result(true)
        } else if call.method == "destoryLib" {
            let isSuccess = EZOpenSDK.destoryLib()
            print("\(TAG) SDK销毁 \(isSuccess ? "成功" : "失败")")
            result(true)
        } else if call.method == "EZPlayer_init" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            
            let deviceSerial:String? = data?["deviceSerial"] as? String
            let cameraNo:Int? = data?["cameraNo"] as? Int
            let verifyCode:String? = data?["verifyCode"] as? String
            
            ezPlayer = EZOpenSDK.createPlayer(withDeviceSerial: deviceSerial!, cameraNo: cameraNo ?? 1)
            ezPlayer.setPlayVerifyCode(verifyCode)
            ezPlayer.delegate = self
            let ysPlayView = YsPlayView()
            ezPlayer.setPlayerView(ysPlayView.view())
            print("\(TAG)注册播放器成功")
            result(true)
        }else if call.method == "startRealPlay" {
            let isSuccess = ezPlayer.startRealPlay()
            print("\(TAG) 开始直播 \(isSuccess ? "成功" : "失败")")
            result(isSuccess)
        }else if call.method == "stopRealPlay" {
            let isSuccess = ezPlayer.stopRealPlay()
            print("\(TAG) 停止直播 \(isSuccess ? "成功" : "失败")")
            result(isSuccess)
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    
   
    
  
}

