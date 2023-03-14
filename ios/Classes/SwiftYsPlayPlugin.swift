//
//  SwiftYsPlayPlugin.swift
//  ys_play
//
//  Created by 潇洒的然然 on 2022/9/6.

import Flutter
import UIKit
import EZOpenSDKFramework

public class SwiftYsPlayPlugin: NSObject, FlutterPlugin,EZPlayerDelegate{
    
    var playerView:UIView?
    let TAG = "荧石SDK=======>"
    var pwResult:FlutterBasicMessageChannel?
    
    init(messenger:FlutterBinaryMessenger){
      super.init()
      pwResult = FlutterBasicMessageChannel(name: Constants.PEI_WANG_CHANNEL, binaryMessenger: messenger,
                                            codec:FlutterStandardMessageCodec.sharedInstance())
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = YsPlayViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: Constants.CHANNEL)
        let channel = FlutterMethodChannel(name: Constants.CHANNEL, binaryMessenger: registrar.messenger())
        
        let instance = SwiftYsPlayPlugin(messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "init_sdk" {
            /// 初始化萤石SDK
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, String>
            if data == nil || data!["appKey"] == nil {
                result(false)
            }else{
                let res:Bool = EZOpenSDK.initLib(withAppKey: data!["appKey"]!)
                print("\(TAG) SDK初始化 \(res ? "成功" : "失败")")
                result(res)
            }
        } else if call.method == "set_access_token" {
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, String>
            if data != nil && data!["accessToken"] != nil {
                EZOpenSDK.setAccessToken(data!["accessToken"]!)
                print("\(TAG)accessToken设置成功")
                result(true)
            }else{
                result(false)
            }
        } else if call.method == "start_config_ap" {
            /// AP配网接口(热点配网)
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            let deviceSerial:String? = data?["deviceSerial"] as? String
            let ssid:String? = data?["ssid"] as? String
            let password:String? = data?["password"] as? String
            let verifyCode:String? = data?["verifyCode"] as? String

            EZOpenSDK.startAPConfigWifi(withSsid: ssid ?? "", password: password ?? "",
                                        deviceSerial: deviceSerial ?? "", verifyCode: verifyCode ?? "", deviceStatus: wifiConfigStatus)
            
        } else if call.method == "start_config_wifi" {
            /// SmartConfig & 声波配网
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            let deviceSerial:String? = data?["deviceSerial"] as? String
            let ssid:String? = data?["ssid"] as? String
            let password:String? = data?["password"] as? String
            let mode:String? = data?["mode"] as? String

            var configMode = EZWiFiConfigMode.smart ////默认wifi配网
            if mode == "wave"{
                //声波配网
                configMode = .wave
            }
            print(">>>>>>>>\(configMode.rawValue)")
            EZOpenSDK.startConfigWifi(ssid ?? "", password: password ?? "", deviceSerial:deviceSerial ?? "",
                                      mode: configMode.rawValue,deviceStatus: wifiConfigStatus)
        } else if call.method == "stop_config" {
            /// 停止配网
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            var mode:String? = data?["mode"] as? String
            if mode == nil {
                mode = "wifi"
            }
            if mode == "wave" || mode == "wifi" {
                let isSuccess:Bool = EZOpenSDK.stopConfigWifi()
                print("\(TAG)停止配网\(isSuccess ? "成功" : "失败")")
                result(isSuccess)
            } else if mode == "ap" {
                EZOpenSDK.stopAPConfigWifi()
                result(true)
            } else {
                result(false)
            }
        }
        else if call.method == "destoryLib" {
            let isSuccess = EZOpenSDK.destoryLib()
            print("\(TAG) SDK销毁 \(isSuccess ? "成功" : "失败")")
            result(true)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    /**
     * 配网回调
     */
    lazy var wifiConfigStatus = { (status:EZWifiConfigStatus,result:String?)  in
        let entity:PeiwangResultEntity = PeiwangResultEntity()
        switch(status){
        case EZWifiConfigStatus.DEVICE_PLATFORM_REGISTED:
            print("\(self.TAG)设备注册平台成功")
            entity.isSuccess = true
            entity.msg = "注册平台成功"
            self.pwResult?.sendMessage(entity.getString())
            EZOpenSDK.stopConfigWifi()
            break
        case .DEVICE_WIFI_CONNECTING:
            print("\(self.TAG)设备正在连接WiFi...")
            break
        case .DEVICE_WIFI_CONNECTED:
            print("\(self.TAG)Wi-Fi连接成功")
            break
        case .DEVICE_ACCOUNT_BINDED:
            print("\(self.TAG)已绑定设备")
            break
        case .DEVICE_WIFI_SENT_SUCCESS:
            print("\(self.TAG)向设备发送WiFi信息成功")
            break
        case .DEVICE_WIFI_SENT_FAILED:
            print("\(self.TAG)向设备发送WiFi信息失败")
            entity.isSuccess = false
            entity.msg = "向设备发送WiFi信息失败"
            self.pwResult?.sendMessage(entity.getString())
            break
        case .DEVICE_PLATFORM_REGIST_FAILED:
            entity.isSuccess = false
            entity.msg = "注册平台失败"
            self.pwResult?.sendMessage(entity.getString())
            break
        default:
            break
        }
    }


}

