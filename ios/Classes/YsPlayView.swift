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

class YsPlayView: NSObject, FlutterPlatformView{
    
    var nativeView : UIView
    
    override init(){
        nativeView = UIView()
        nativeView.frame = CGRect(x: 0, y: 0, width: 720, height: 1280)
        super.init()
    }
    
    func view() -> UIView {
        return nativeView;
    }


//    func callMessage (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
//      // Note: this method is invoked on the UI thread.
//      // Handle battery messages.
//        if call.method == "start" {
//            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
//            if data != nil {
//                print(data!)
//            }
//
//            print(type(of:data))
//
//            EZOpenSDK.setAccessToken(data?["token"] as? String)
//
//            player = EZOpenSDK.createPlayer(withDeviceSerial: data?["deviceSerial"] as? String, cameraNo: data?["cameraNo"] as! Int)
////            player.delegate = self
//
//
//            let verifyCode = data?["verifyCode"] as? String
//            if(verifyCode != nil) {
//                player.setPlayVerifyCode(data?["verifyCode"] as? String)
//            } else {
//                print("verifyCode is null !!!")
//            }
//
//            player.setPlayerView(_view)
//            player.startRealPlay()
//            print("荧石SDK=====>开始直播*")
//            result(true)
//        }
//        else if call.method == "end" {
//            player.stopRealPlay()
//            player.destoryPlayer()
//            print("荧石SDK=====>停止直播*")
//            result(true)
//        }  else if call.method == "queryPlayback" {
////            let data:Optional<Dictionary> = call.arguments as! Dictionary<String, Any>
//            print("荧石SDK=====>回放查询")
//            result(true)
//        }
//        else if call.method == "startRealPlay" {
//            player.startRealPlay()
//            print("荧石SDK=====>开始直播")
//            result(true)
//        }
//        else if call.method == "stopRealPlay" {
//            player.stopRealPlay()
//            print("荧石SDK=====>停止直播")
//            result(true)
//        }
//        else if call.method == "release" {
//            player.destoryPlayer()
//            print("荧石SDK=====>release")
//            result(true)
//        }
//        else if call.method == "queryPlayback" {
////            player.destoryPlayer()
//            result("success")
//        }

//
//        
//        else if call.method == "getOSDTime" {
//            let odsTime = player.getOSDTime()
//            let resultNum = Int(odsTime?.timeIntervalSince1970 ?? 0) * 1000;
//            print("荧石SDK=====>获取播放节点成功")
//            result(resultNum)
//        }
//        else if call.method == "sound" {
//            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
//            if(data?["Sound"] as! Bool) {
//                player.openSound();
//                print("荧石SDK=====>打开声音")
//            } else {
//                player.closeSound();
//                print("荧石SDK=====>关闭声音")
//            }
//            result(true)
//        }
//        else {
//            result(FlutterMethodNotImplemented)
//        }
//    }
}
