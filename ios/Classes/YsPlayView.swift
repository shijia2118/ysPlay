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
import Photos


class YsPlayView: NSObject, FlutterPlatformView,EZPlayerDelegate{
    
    var nativeView : UIView
    var callback: ((_ tmpView:UIView)->())?
    var ezPlayer:EZPlayer
    var _talkPlayer:EZPlayer?
    private var messenger:FlutterBinaryMessenger
    var ysResult:FlutterBasicMessageChannel?
    private var videoPath:String? //视频地址
    var supportTalk:Int = 0 //对讲能力 0不支持 1全双工 3半双工
    var isPhone2Dev:Int = 0 //1手机端说设备端听 0手机端听设备端说
    
    let TAG = "荧石SDK=======>"
    
    init(binaryMessenger:FlutterBinaryMessenger){
        ezPlayer = EZOpenSDK.createPlayer(withDeviceSerial: "123", cameraNo: 1)
        nativeView = UIView()

        self.messenger = binaryMessenger
        super.init()
        ysResult = FlutterBasicMessageChannel(name: Constants.PLAYER_STATUS_CHANNEL, binaryMessenger: messenger, codec:
          FlutterStandardMessageCodec.sharedInstance() )
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
            print("\(TAG)accessToken设置成功")
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
            print("\(TAG)注册播放器成功")
            result(true)
        } else if call.method == "startRealPlay" {
            let isSuccess = ezPlayer.startRealPlay()
            print("\(TAG) 开始直播 \(isSuccess ? "成功" : "失败")")
            result(isSuccess)
        } else if call.method == "stopRealPlay" {
            let isSuccess = ezPlayer.stopRealPlay()
            print("\(TAG) 停止直播 \(isSuccess ? "成功" : "失败")")
            result(isSuccess)
        } else if call.method == "startPlayback" {
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
        } else if call.method == "stopPlayback" {
            let bool = ezPlayer.stopPlayback()
            print("\(TAG)停止回放\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "pause_play_back"{
            let bool = ezPlayer.pausePlayback()
            print("\(TAG)暂停回放\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "resume_play_back"{
            let bool = ezPlayer.resumePlayback()
            print("\(TAG)恢复回放\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "openSound"{
            let bool = ezPlayer.openSound()
            print("\(TAG)打开声音\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "closeSound"{
            let bool = ezPlayer.closeSound()
            print("\(TAG)关闭声音\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "capturePicture"{
            let image =  ezPlayer.capturePicture(10)
            if image != nil {
                saveImage2Library(image: image!,callback:  {isSuccess in
                    print("\(self.TAG)截屏\(isSuccess ? "成功" : "失败")")
                    result(isSuccess)
                })
            }
        } else if call.method == "start_record" {
            //录屏前,先结束上一次录像
            ezPlayer.stopLocalRecordExt({(isSuccess : Bool) in
                let documentDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                      FileManager.SearchPathDomainMask.userDomainMask, true).first
                let date = String(DateUtil.getCurrentTimeStamp())
                self.videoPath = "\(documentDir ?? "")/\(date).mp4"
                let isSuccess = self.ezPlayer.startLocalRecord(withPathExt: self.videoPath)
                print("\(self.TAG)录屏\(isSuccess ? "成功": "失败")")
                result(isSuccess)
            })
        }else if call.method == "stop_record"{
            ezPlayer.stopLocalRecordExt({(isSuccess : Bool) in
                print("\(self.TAG)停止录屏\(isSuccess ? "成功": "失败")")
                if self.videoPath != nil {
                    self.saveVideo2Library(path: self.videoPath!, callback: {success in
                        result(success)
                    })
                }else {
                    result(false)
                }
             })
        }else if call.method == "set_video_level"{
            ///设置视频清晰度
            ///videoLevel:  0流畅，1均衡，2高清，3超清。默认高清
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            let deviceSerial:String? = data?["deviceSerial"] as? String
            var cameraNo:Int? = data?["cameraNo"] as? Int
            var videoLevel:Int? = data?["videoLevel"] as? Int
            
            if cameraNo == nil {
                cameraNo = 1
            }
            if(videoLevel == nil){
                videoLevel = 2
            }
            if deviceSerial == nil{
                result(false)
            }
            let videoLevelType = getVideoLevelType(videoLevel: videoLevel!)
          
            EZOpenSDK.setVideoLevel(deviceSerial!, cameraNo: cameraNo!, videoLevel: videoLevelType, completion: {
                (error) in
                if error != nil{
                    print(">>>>>>>>error==\(String(describing: error))")
                    result(false)
                }else{
                    result(true)
                }
            })
        } else if call.method == "start_voice_talk"{
          
            //获取参数
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            let deviceSerial:String? = data?["deviceSerial"] as? String
            let cameraNo:Int? = data?["cameraNo"] as? Int
            let verifyCode:String? = data?["verifyCode"] as? String
            if data?["supportTalk"] != nil {
                supportTalk = (data!["supportTalk"] as! Int)
            }
            if data?["isPhone2Dev"] != nil {
                isPhone2Dev = (data!["isPhone2Dev"] as! Int)
            }
            //创建对讲器
            _talkPlayer = EZOpenSDK.createPlayer(withDeviceSerial: deviceSerial!, cameraNo: cameraNo ?? 1)
            _talkPlayer!.setPlayVerifyCode(verifyCode)
            _talkPlayer!.delegate = self
            _talkPlayer!.startVoiceTalk()
            
            //半双工设备需要设置
            if supportTalk == 3{
                if isPhone2Dev == 0 {
                    //手机端听 设备端说
                    ezPlayer.openSound()
                    _talkPlayer!.audioTalkPressed(false)
                } else if isPhone2Dev == 1{
                    //手机端说 设备端听
                    ezPlayer.closeSound()
                    _talkPlayer!.audioTalkPressed(true)
                }
            }
            //需成对使用，否则会出各种问题
            _talkPlayer!.stopVoiceTalk()
            print("\(TAG)\(isPhone2Dev == 1 ? "说" : "听")")
            result(true)
        } else if call.method == "stop_voice_talk" {
            result(stopVoiceTalk())
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    /**
     * 停止对讲
     */
    private func stopVoiceTalk() -> Bool {
        if _talkPlayer != nil {
            let isSuccess = _talkPlayer!.stopVoiceTalk()
            print("\(self.TAG)结束对讲\(isSuccess ? "成功": "失败")")
            _talkPlayer!.delegate = nil
            _talkPlayer!.destoryPlayer()
            _talkPlayer = nil
            return isSuccess
        }else{
            return true
        }
    }
    
    /**
     * 直播、回放和对讲 错误回调
     */
    public func player(_ player: EZPlayer!, didPlayFailed error: Error!) {

        let entity:YsPlayerStatusEntity = YsPlayerStatusEntity()
        entity.isSuccess = false
        if player.isEqual(_talkPlayer) {
            entity.talkErrorInfo = error.localizedDescription
        }else if player.isEqual(ezPlayer) {
            entity.playErrorInfo = error.localizedDescription
        }
        ysResult?.sendMessage(entity.getString())
    }
    
    /**
     * 直播、回放和对讲 成功后收到的状态码
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
        case 4:
            print("\(TAG)对讲开始")
            dict.updateValue(true, forKey: "isSuccess")
            break
        case 5:
            print("\(TAG)对讲结束")
            dict.updateValue(true, forKey: "isSuccess")
            break
        default: break
        }
        let message = convertDictionaryToJson(dict: dict)
        ysResult?.sendMessage(message)
    }
    
    /**
     * 字典转JSON
     */
    func convertDictionaryToJson(dict : Dictionary<String,Any>) -> String {
        let data = try? JSONSerialization.data(withJSONObject: dict,options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
        return jsonStr! as String
    }
    
    /**
     *  保存图片到相册
     */
    private func saveImage2Library(image:UIImage,callback:@escaping(_ result:Bool)->Void ) {
        PHPhotoLibrary.shared().performChanges(
            {PHAssetChangeRequest.creationRequestForAsset(from: image)},
            completionHandler:{(isSuccess,error) in
                DispatchQueue.main.async {
                    callback(isSuccess)
            }
        })
    }
    
    
    /**
     * 保存视频到相册
     */
    private func saveVideo2Library(path:String, callback:@escaping(_ result:Bool)->Void ) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: path))
        }){(success,error) in
            DispatchQueue.main.async {
                if !success {
                    print(">>>>>>>>>保存相册失败:\(String(describing: error))")
                }
                callback(success)
            }
        }
    }
    
    /*
     * 根据videoLevel返回EZVideoLevelType
     */
    private func getVideoLevelType (videoLevel:Int) -> EZVideoLevelType {
        var videolevelType:EZVideoLevelType = EZVideoLevelType.high
        switch videoLevel {
        case 0:
            videolevelType = EZVideoLevelType.low
        case 1:
            videolevelType = EZVideoLevelType.middle
        case 2:
            videolevelType = EZVideoLevelType.high
        case 3:
            videolevelType = EZVideoLevelType.superHigh
        default:
            break
        }
        return videolevelType
    }
    
   
      
    
    
}
