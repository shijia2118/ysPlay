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
    var ezPlayer:EZPlayer?
    var _talkPlayer:EZPlayer?
    private var messenger:FlutterBinaryMessenger
    var ysResult:FlutterBasicMessageChannel?
    private var videoPath:String? //视频地址
    var supportTalk:Int = 0 //对讲能力 0不支持 1全双工 3半双工
    var isPhone2Dev:Int = 1 //1手机端说设备端听 0手机端听设备端说
    
    let TAG = "荧石SDK=======>"
    
    init(binaryMessenger:FlutterBinaryMessenger){
        nativeView = UIView()

        self.messenger = binaryMessenger
        super.init()
        ysResult = FlutterBasicMessageChannel(name: Constants.PLAYER_STATUS_CHANNEL, binaryMessenger: messenger, codec:
          FlutterStandardMessageCodec.sharedInstance() )
        
        let channel = FlutterMethodChannel(name: Constants.CHANNEL, binaryMessenger: messenger)
        channel.setMethodCallHandler(self.callMessage)
    }
    

    func view() -> UIView {
        return nativeView;
    }
    

    func callMessage (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {

        if call.method == "set_access_token" {
            /// 设置"accessToken"
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, String>
            if data != nil && data!["accessToken"] != nil {
                EZOpenSDK.setAccessToken(data!["accessToken"]!)
                print("\(TAG)accessToken设置成功")
                result(true)
            }else{
                result(false)
            }
        } else if call.method == "startPlayback" {
            /// 开始回放
            if ezPlayer != nil {
                ezPlayer?.stopPlayback()
                ezPlayer = nil
            }
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            let deviceSerial = data?["deviceSerial"] as? String //设备序列号
            let cameraNo = data?["cameraNo"] as? Int
            let verifyCode = data?["verifyCode"] as? String
            let startTime = data?["startTime"] as? Int
            let endTime = data?["endTime"] as? Int
            
            if deviceSerial == nil || startTime == nil || endTime == nil {
                result(false)
                return
            }
            // 注册播放器
            ezPlayer = createEzPlayer(deviceSerial: deviceSerial!, cameraNo: cameraNo, verifyCode: verifyCode)
            
            let recordFile = EZDeviceRecordFile()
            recordFile.type = 1;
            recordFile.channelType = "D";
            let zone = NSTimeZone.system
            let interval = zone.secondsFromGMT()
            let startDate = Date(timeIntervalSince1970: TimeInterval(startTime!)/1000).addingTimeInterval(TimeInterval(interval))
            recordFile.startTime = startDate
            
            let endDate = Date(timeIntervalSince1970: TimeInterval(endTime!)/1000).addingTimeInterval(TimeInterval(interval))
            recordFile.stopTime = endDate
            
            let bool = ezPlayer!.startPlayback(fromDevice: recordFile)
            print("\(TAG)开始回放\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "pause_play_back"{
            /// 暂停回放
            if ezPlayer == nil {
                result(false)
                return
            }
            let bool = ezPlayer!.pausePlayback()
            print("\(TAG)暂停回放\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "resume_play_back"{
            /// 恢复回放
            if ezPlayer == nil {
                result(false)
                return
            }
            let bool = ezPlayer!.resumePlayback()
            print("\(TAG)恢复回放\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "stopPlayback" {
            /// 停止回放
            if ezPlayer == nil {
                result(false)
                return
            }
            let bool = ezPlayer!.stopPlayback()
            print("\(TAG)停止回放\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "startRealPlay" {
            if(ezPlayer != nil){
                // 先停止
                ezPlayer!.stopRealPlay();
                ezPlayer = nil;
            }
            
            let data:Optional<Dictionary> = call.arguments as? Dictionary<String, Any>
            let deviceSerial = data?["deviceSerial"] as? String //设备序列号
            let cameraNo = data?["cameraNo"] as? Int
            let verifyCode = data?["verifyCode"] as? String
            
            if deviceSerial == nil {
                result(false)
                return
            }
            // 注册播放器
            ezPlayer = createEzPlayer(deviceSerial: deviceSerial!, cameraNo: cameraNo, verifyCode: verifyCode)

            let isSuccess = ezPlayer!.startRealPlay()
            print("\(TAG) 开始直播 \(isSuccess ? "成功" : "失败")")
            result(isSuccess)
        } else if call.method == "stopRealPlay" {
            /// 停止直播
            if ezPlayer == nil {
                result(false)
                return
            }
            let isSuccess = ezPlayer!.stopRealPlay()
            print("\(TAG) 停止直播 \(isSuccess ? "成功" : "失败")")
            result(isSuccess)
        }  else if call.method == "openSound"{
            /// 打开声音
            if ezPlayer == nil {
                result(false)
                return
            }
            let bool = ezPlayer!.openSound()
            print("\(TAG)打开声音\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "closeSound"{
            /// 关闭声音
            if ezPlayer == nil {
                result(false)
                return
            }
            let bool = ezPlayer!.closeSound()
            print("\(TAG)关闭声音\(bool ? "成功" : "失败")")
            result(bool)
        } else if call.method == "capturePicture"{
            /// 截屏
            if ezPlayer == nil {
                result(false)
                return
            }
            let image =  ezPlayer!.capturePicture(10)
            if image != nil {
                saveImage2Library(image: image!,callback:  {isSuccess in
                    print("\(self.TAG)截屏\(isSuccess ? "成功" : "失败")")
                    result(isSuccess)
                })
            } else {
                result(false)
            }
        } else if call.method == "start_record" {
            /// 开始录像
            if ezPlayer == nil {
                result(false)
                return
            }
            //录屏前,先结束上一次录像
            ezPlayer!.stopLocalRecordExt({(isSuccess : Bool) in
                let documentDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                      FileManager.SearchPathDomainMask.userDomainMask, true).first
                let date = String(DateUtil.getCurrentTimeStamp())
                self.videoPath = "\(documentDir ?? "")/\(date).mp4"
                let isSuccess = self.ezPlayer!.startLocalRecord(withPathExt: self.videoPath)
                print("\(self.TAG)录屏\(isSuccess ? "成功": "失败")")
                result(isSuccess)
            })
        } else if call.method == "stop_record"{
            /// 停止录像
            if ezPlayer == nil {
                result(false)
                return
            }
            ezPlayer!.stopLocalRecordExt({(isSuccess : Bool) in
                print("\(self.TAG)停止录屏\(isSuccess ? "成功": "失败")")
                if self.videoPath != nil {
                    self.saveVideo2Library(path: self.videoPath!, callback: {success in
                        result(success)
                    })
                }else {
                    result(false)
                }
             })
        } else if call.method == "set_video_level"{
            /// 设置视频清晰度
            /// videoLevel:  0流畅，1均衡，2高清，3超清。默认高清
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
                return
            }
            let videoLevelType = getVideoLevelType(videoLevel: videoLevel!)
          
            EZOpenSDK.setVideoLevel(deviceSerial!, cameraNo: cameraNo!, videoLevel: videoLevelType, completion: { error in
                print(">>>>>>>>error==\(String(describing: error))")
                result(false)
            })
            result(true)
        } else if call.method == "start_voice_talk"{
            /// 开始对讲
            if ezPlayer != nil {
                ezPlayer!.closeSound() //关闭视频播放声音
            }
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
            if _talkPlayer == nil {
                //创建对讲器
                _talkPlayer = EZOpenSDK.createPlayer(withDeviceSerial: deviceSerial!, cameraNo: cameraNo ?? 1)
                _talkPlayer!.setPlayVerifyCode(verifyCode)
                _talkPlayer!.delegate = self
            }else{
                _talkPlayer!.stopVoiceTalk()
            }
            //开启对讲
            _talkPlayer!.startVoiceTalk()
        } else if call.method == "stop_voice_talk" {
            /// 停止对讲
            var isSuccess : Bool = true
            if _talkPlayer != nil {
                isSuccess = _talkPlayer!.stopVoiceTalk()
                print("\(self.TAG)结束对讲\(isSuccess ? "成功": "失败")")
                _talkPlayer!.delegate = nil
                _talkPlayer!.destoryPlayer()
                _talkPlayer = nil
            }
            result(isSuccess)
        } else if call.method == "dispose" {
            if ezPlayer != nil {
                ezPlayer!.destoryPlayer()
                ezPlayer = nil
            }
            if _talkPlayer != nil {
                _talkPlayer!.destoryPlayer()
                _talkPlayer = nil
            }
        } else {
            result(FlutterMethodNotImplemented)
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
            if _talkPlayer != nil {
                //半双工设备需要设置
                if supportTalk == 3{
                    if isPhone2Dev == 0 {
                        //手机端听 设备端说
                        _talkPlayer!.audioTalkPressed(false)
                    } else if isPhone2Dev == 1{
                        //手机端说 设备端听
                        _talkPlayer!.audioTalkPressed(true)
                    }
                }
            }
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
    
    /// 注册播放器
    private func createEzPlayer(deviceSerial:String,cameraNo:Int?,verifyCode:String?) -> EZPlayer {
        let player = EZOpenSDK.createPlayer(withDeviceSerial: deviceSerial, cameraNo: cameraNo ?? 1)
        if verifyCode != nil {
            player.setPlayVerifyCode(verifyCode)
        }
        player.delegate = self
        player.setPlayerView(nativeView)
        print("\(TAG)注册播放器成功")
        return player
    }
    
   

    
    
}
