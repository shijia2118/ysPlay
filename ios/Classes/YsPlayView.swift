//
//  EZPlayerView.swift
//  Runner
//
//  Created by py on 2021/8/21.
//

import Foundation
import Flutter
import UIKit
import EZOpenSDKFramework

class YsPlayView: NSObject, FlutterPlatformView, EZPlayerDelegate  {
    private var _view: UIView
    private var messenger: FlutterBinaryMessenger
    var player: EZPlayer

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger: FlutterBinaryMessenger){
        _view = UIView()
        self.messenger = binaryMessenger
        self.player = EZOpenSDK.createPlayer(withDeviceSerial: "123", cameraNo: 1)
        super.init()
//        createNativeView(view: _view)
        initMethodChannel()
        player.destoryPlayer()
    }

    func initMethodChannel(){
        let batteryChannel = FlutterMethodChannel(name: "com.example.ys_play", binaryMessenger: messenger)
        batteryChannel.setMethodCallHandler(self.callMessage)
    }

    func view() -> UIView {

        return _view;
    }

    func createNativeView(view _view: UIView){
        _view.backgroundColor = UIColor.blue
        let nativeLabel = UILabel()
//        nativeLabel.text = "Native text from iOS"
        nativeLabel.textColor = UIColor.black
        nativeLabel.textAlignment = .center
        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
        _view.addSubview(nativeLabel)
    }

    func callMessage (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
      // Note: this method is invoked on the UI thread.
      // Handle battery messages.
        if call.method == "start" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            if data != nil {
                print(data!)
            }

            print(type(of:data))

            EZOpenSDK.setAccessToken(data?["token"] as? String)

            player = EZOpenSDK.createPlayer(withDeviceSerial: data?["deviceSerial"] as? String, cameraNo: data?["cameraNo"] as! Int)
//            player.delegate = self


            let verifyCode = data?["verifyCode"] as? String
            if(verifyCode != nil) {
                player.setPlayVerifyCode(data?["verifyCode"] as? String)
            } else {
                print("verifyCode is null !!!")
            }

            player.setPlayerView(_view)
            player.startRealPlay()
            print("荧石SDK=====>开始直播*")
            result(true)
        }
        else if call.method == "end" {
            player.stopRealPlay()
            player.destoryPlayer()
            print("荧石SDK=====>停止直播*")
            result(true)
        }  else if call.method == "queryPlayback" {
//            let data:Optional<Dictionary> = call.arguments as! Dictionary<String, Any>
            print("荧石SDK=====>回放查询")
            result(true)
        }
        else if call.method == "startRealPlay" {
            player.startRealPlay()
            print("荧石SDK=====>开始直播")
            result(true)
        }
        else if call.method == "stopRealPlay" {
            player.stopRealPlay()
            print("荧石SDK=====>停止直播")
            result(true)
        }
        else if call.method == "release" {
            player.destoryPlayer()
            print("荧石SDK=====>release")
            result(true)
        }
        else if call.method == "queryPlayback" {
//            player.destoryPlayer()
            result("success")
        }
        else if call.method == "EZPlayer_init" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            if data != nil {
                print(data!)
            }
        
            print(type(of:data))

            player = EZOpenSDK.createPlayer(withDeviceSerial: data?["deviceSerial"] as? String, cameraNo: data?["cameraNo"] as! Int)
//            player.delegate = self

            let verifyCode = data?["verifyCode"] as? String
            if(verifyCode != nil) {
                player.setPlayVerifyCode(data?["verifyCode"] as? String)
            } else {
                print("verifyCode is null !!!")
            }

            player.setPlayerView(_view)
            print("荧石SDK=====>注册播放器成功")
            result(true)
        }
        else if call.method == "startPlayback" {
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
            
            let bool = player.startPlayback(fromDevice: recordFile)
        
            print("荧石SDK=====>开始回放")
            result(bool)
        }
        else if call.method == "stopPlayback" {
            player.stopPlayback()
            print("荧石SDK=====>停止回放")

            result(true)
        }
        else if call.method == "getOSDTime" {
            let odsTime = player.getOSDTime()
            let resultNum = Int(odsTime?.timeIntervalSince1970 ?? 0) * 1000;
            print("荧石SDK=====>获取播放节点成功")
            result(resultNum)
        }
        else if call.method == "sound" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            if(data?["Sound"] as! Bool) {
                player.openSound();
                print("荧石SDK=====>打开声音")
            } else {
                player.closeSound();
                print("荧石SDK=====>关闭声音")
            }
            result(true)
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
}
