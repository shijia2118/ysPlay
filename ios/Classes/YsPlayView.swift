//
//  EZPlayerView.swift
//  Runner
//
//  Created by 潇洒的然然 on 2022/12/01.
//

import Foundation
import Flutter
import UIKit
import EZOpenSDKFramework


class YsPlayView: NSObject, FlutterPlatformView,EZPlayerDelegate{
    
    var nativeView : UIView
    var callback: ((_ tmpView:UIView)->())?
    var ezPlayer:EZPlayer
    private var messenger:FlutterBinaryMessenger
    
    let TAG = "荧石SDK=======>"
    
     init(
        binaryMessenger:FlutterBinaryMessenger
        
    ){
        ezPlayer = EZOpenSDK.createPlayer(withDeviceSerial: "123", cameraNo: 1)
        nativeView = UIView()

        self.messenger = binaryMessenger
        super.init()
        let channel = FlutterMethodChannel(name: Constants.CHANNEL, binaryMessenger: messenger)
        channel.setMethodCallHandler(self.callMessage)
        ezPlayer.destoryPlayer()
    }
    

    func view() -> UIView {
        return nativeView;
    }
    
  


    func callMessage (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        if call.method == "set_access_token" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, String>
            EZOpenSDK.setAccessToken(data?["accessToken"] as? String)
            print("accessToken设置成功")
            result(true)
        } else if call.method == "EZPlayer_init" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            
            let deviceSerial:String? = data?["deviceSerial"] as? String
            let cameraNo:Int? = data?["cameraNo"] as? Int
            let verifyCode:String? = data?["verifyCode"] as? String
            
            ezPlayer = EZOpenSDK.createPlayer(withDeviceSerial: deviceSerial!, cameraNo: cameraNo ?? 1)
            ezPlayer.setPlayVerifyCode(verifyCode)
            ezPlayer.delegate = self

            ezPlayer.setPlayerView(nativeView)
            print("注册播放器成功")
            result(true)
        } else if call.method == "startRealPlay" {
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
