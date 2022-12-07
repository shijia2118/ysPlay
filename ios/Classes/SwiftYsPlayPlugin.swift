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
    
    var ezPlayer:EZPlayer
    var ysResult:FlutterBasicMessageChannel
    var playerView:UIView?
    let TAG = "荧石SDK=======>"
    
    init(messenger:FlutterBinaryMessenger){
       
      ezPlayer = EZOpenSDK.createPlayer(withDeviceSerial: "123", cameraNo: 1)
     
      ysResult = FlutterBasicMessageChannel(name: Constants.PLAYER_STATUS_CHANNEL, binaryMessenger: messenger, codec:
        FlutterStandardMessageCodec.sharedInstance() )
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
                result(res)
            }
        }else if call.method == "set_access_token" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, String>
            EZOpenSDK.setAccessToken(data?["accessToken"] as? String)
            print("accessToken设置成功")
            result(true)
        }else if call.method == "destoryLib" {
            let isSuccess = EZOpenSDK.destoryLib()
            print("\(TAG) SDK销毁 \(isSuccess ? "成功" : "失败")")
            result(true)
        }
//        else if call.method == "EZPlayer_init" {
//
//            let ysFactory = YsPlayViewFactory()
//            ysFactory.callback = {[weak self] (tmpView:UIView) in
//                self?.playerView = tmpView
//                print(">>>>>>>>view0==\(tmpView)")
//            }
//
//
//
//
//            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
//
//            let deviceSerial:String? = data?["deviceSerial"] as? String
//            let cameraNo:Int? = data?["cameraNo"] as? Int
//            let verifyCode:String? = data?["verifyCode"] as? String
//
//            ezPlayer = EZOpenSDK.createPlayer(withDeviceSerial: deviceSerial!, cameraNo: cameraNo ?? 1)
//            ezPlayer.setPlayVerifyCode(verifyCode)
//            ezPlayer.delegate = self
//
////            let ysPlayView = YsPlayView()
////            ezPlayer.setPlayerView(ysPlayView.nativeView)
//
////            ezPlayer.setPlayerView(playerView)
//
//            print("\(TAG)注册播放器成功")
//            result(true)
//        }
        else if call.method == "startRealPlay" {
            let isSuccess = ezPlayer.startRealPlay()
            print("\(TAG) 开始直播 \(isSuccess ? "成功" : "失败")")
            result(isSuccess)
        }else if call.method == "stopRealPlay" {
            let isSuccess = ezPlayer.stopRealPlay()
            print("\(TAG) 停止直播 \(isSuccess ? "成功" : "失败")")
            result(isSuccess)
        }else if call.method == "startPlayback" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            let startTime = data?["startTime"] as! Int
            let endTime = data?["endTime"] as! Int
            
            let recordFile = EZDeviceRecordFile()
            recordFile.type = 1;
            recordFile.channelType = "D";
            let startDate = Date(timeIntervalSince1970: TimeInterval(startTime)/1000)
            recordFile.startTime = startDate
            
            let endDate = Date(timeIntervalSince1970: TimeInterval(endTime)/1000)
            recordFile.stopTime = endDate
            print(startTime)
            print("ios startTime")
            print(TimeInterval(startTime))
            
            let nowDate = Date()
            print("ios nowDate")
            print(nowDate.timeIntervalSince1970)
            
            let bool = ezPlayer.startPlayback(fromDevice: recordFile)
            print("\(TAG)开始回放\(bool ? "成功" : "失败")")
            result(bool)
        }else if call.method == "stopPlayback" {
            let bool = ezPlayer.stopPlayback()
            print("\(TAG)停止回放\(bool ? "成功" : "失败")")
            result(bool)
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    /*
       直播、回放和对讲 错误回调
     */
    public func player(_ player: EZPlayer!, didPlayFailed error: Error!) {
        print(">>>>>>>>>>>>error====\(String(describing: error))")
        ysResult.sendMessage(false)
        
    }
    
    /*
       直播、回放和对讲 成功后收到的状态码
     */
    public func player(_ player: EZPlayer!, didReceivedMessage messageCode: Int) {
        var dict = [String:Any]()

        switch messageCode {
        case 1:
            print("\(TAG)直播开始")
            dict.updateValue(true, forKey: "isSuccess")
            break
        case 11:
            print("\(TAG)录像开始")
            dict.updateValue(true, forKey: "isSuccess")
            break
        default:
            break
        }
        let message = convertDictionaryToJson(dict: dict)
        ysResult.sendMessage(message)
    }
    
    /*
     字典转JSON
     */
    func convertDictionaryToJson(dict : Dictionary<String,Any>) -> String {
        let data = try? JSONSerialization.data(withJSONObject: dict,options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
        return jsonStr! as String
    }
    
    
    
   
    
  
}

