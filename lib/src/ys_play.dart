import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ys_play/src/entity/capacity_response_entity.dart';
import 'package:ys_play/src/entity/ys_player_status.dart';
import 'package:ys_play/src/entity/ys_pw_result.dart';
import 'package:ys_play/src/entity/ys_response_entity.dart';
import 'package:ys_play/src/ys_http_api.dart';
import 'package:ys_play/ys.dart';

class YsPlay {
  static const _channel = MethodChannel("com.example.ys_play");

  static const BasicMessageChannel<dynamic> _nativeYs =
      BasicMessageChannel("com.example.ys_play/record_file", StandardMessageCodec());

  /// 播放状态
  static const BasicMessageChannel<dynamic> _playerStatus =
      BasicMessageChannel("com.example.ys_play/player_status", StandardMessageCodec());

  /// 配网结果渠道
  static const BasicMessageChannel<dynamic> _pwResultChannel =
      BasicMessageChannel("com.example.ys_play/pei_wang", StandardMessageCodec());

  static final Map<int, Function> _callBackFuncMap = {};

  static void initMessageHandler() {
    _nativeYs.setMessageHandler(
      (dynamic str) async {
        Map<String, dynamic> data = json.decode(str);

        if (data['code'] == 'RecordFile') {
          var fileData = json.decode(data['Data']);
          if (fileData != null) {
            var recordFileList = [];
            fileData.forEach((v) {
              recordFileList.add(YsRecordFile.fromJson(v));
            });

            if (_callBackFuncMap.containsKey(data['callBackFuncId'])) {
              try {
                var func = _callBackFuncMap.remove(data['callBackFuncId']);
                if (func != null) func(recordFileList);
                // ignore: empty_catches
              } catch (e) {}
            }
          }
        }
      },
    );
  }

  ///播放状态监听
  static void onResultListener(Function(YsPlayerStatus) onResult) {
    _playerStatus.setMessageHandler((message) async {
      if (message != null && message is String && message.isNotEmpty) {
        Map<String, dynamic> msg = json.decode(message);
        onResult(YsPlayerStatus.fromJson(msg));
      }
    });
  }

  ///配网结果监听
  static void peiwangResultListener(Function(YsPwResult) onResult) {
    _pwResultChannel.setMessageHandler((message) async {
      if (message != null && message is String && message.isNotEmpty) {
        Map<String, dynamic> msg = json.decode(message);
        onResult(YsPwResult.fromJson(msg));
      }
    });
  }

  /// 初始化萤石SDK
  /// 传参 appKey 注册萤石平台后生成
  /// 返回值 bool
  static Future<bool> initSdk(String appKey) async {
    // YsPlay.initMessageHandler();
    bool result = await _channel.invokeMethod("init_sdk", {'appKey': appKey});
    return result;
  }

  /// 应用退出时，销毁萤石SDK
  static Future<void> destroyLib() async {
    await _channel.invokeMethod("destroyLib");
  }

  /// 设置accessToken
  /// 传参 accessToken,该参数有效期为7天，需要从服务端获取
  /// 返回值：bool
  static Future<bool> setAccessToken(String accessToken) async {
    bool result = await _channel.invokeMethod("set_access_token", {'accessToken': accessToken});
    return result;
  }

  /// 注册播放器
  static Future<bool> initEZPlayer(
    String deviceSerial,
    String verifyCode,
    int cameraNo,
  ) async {
    bool result = await _channel.invokeMethod("EZPlayer_init", {
      'deviceSerial': deviceSerial,
      'verifyCode': verifyCode,
      'cameraNo': cameraNo,
    });
    return result;
  }

  // 打开声音
  static Future<bool> openSound() async {
    bool result = await _channel.invokeMethod("openSound");
    return result;
  }

  // 关闭声音
  static Future<bool> closeSound() async {
    bool result = await _channel.invokeMethod("closeSound");
    return result;
  }

  // 开始直播
  static Future<bool> startRealPlay() async {
    await _channel.invokeMethod("startRealPlay");
    return true;
  }

  // 停止直播
  static Future<bool> stopRealPlay() async {
    await _channel.invokeMethod("stopRealPlay");
    return true;
  }

  // 开始回放
  static Future<bool> startPlayback(int startDt, int endDt) async {
    bool result = await _channel.invokeMethod("startPlayback", {
      'startTime': startDt,
      'endTime': endDt,
    });
    return result;
  }

  // 停止回放
  static Future<bool> stopPlayback() async {
    await _channel.invokeMethod("stopPlayback");
    return true;
  }

  // 暂停回放
  static Future<bool> pausePlayback() async {
    bool result = await _channel.invokeMethod("pause_play_back");
    return result;
  }

  // 恢复回放
  static Future<bool> resumePlayback() async {
    bool result = await _channel.invokeMethod("resume_play_back");
    return result;
  }

  // 查询录制视频(只实现了android)
  static Future<bool> queryPlayback(YsViewRequestEntity request, Function func) async {
    int id = DateTime.now().millisecondsSinceEpoch;
    while (_callBackFuncMap.containsKey(id)) {
      id = DateTime.now().millisecondsSinceEpoch;
    }
    _callBackFuncMap[id] = func;

    await _channel.invokeMethod("queryPlayback", {
      'callBackFuncId': id,
      'startTime': request.startTime,
      'endTime': request.endTime,
      'deviceSerial': request.deviceSerial,
      'cameraNo': request.cameraNo,
      'verifyCode': request.verifyCode,
    });
    return true;
  }

  static Future<int> getOSDTime() async {
    var result = await _channel.invokeMethod("getOSDTime");
    return result;
  }

  ///结束直播
  static Future<bool> endVideo() async {
    await _channel.invokeMethod("end");
    return true;
  }

  ///截屏
  static Future capturePicture() async {
    var result = await _channel.invokeMethod("capturePicture");
    return result;
  }

  ///设置视频清晰度
  static Future<bool> setVideoLevel({
    required String deviceSerial,
    int cameraNo = 1,
    int videoLevel = 2,
  }) async {
    var result = await _channel.invokeMethod(
      "set_video_level",
      {
        "deviceSerial": deviceSerial,
        "cameraNo": cameraNo,
        "videoLevel": videoLevel,
      },
    );
    return result;
  }

  ///控制云台
  static Future<YsResponseEntity> ptzStart({
    required String accessToken,
    required String deviceSerial,
    required int channelNo,
    required int direction,
    int? speed,
  }) async {
    return await YsHttpApi.devPtzStart(
      accessToken: accessToken,
      deviceSerial: deviceSerial,
      channelNo: channelNo,
      direction: direction,
      speed: speed,
    );
  }

  ///停止控制
  static Future<YsResponseEntity> ptzStop({
    required String accessToken,
    required String deviceSerial,
    required int channelNo,
    int? direction,
  }) async {
    return await YsHttpApi.devPtzStop(
      accessToken: accessToken,
      deviceSerial: deviceSerial,
      channelNo: channelNo,
      direction: direction,
    );
  }

  ///获取设备能力集
  static Future<CapacityResponseEntity> getDevCapacity({
    required String accessToken,
    required String deviceSerial,
  }) async {
    return await YsHttpApi.getDevCapacity(
      accessToken: accessToken,
      deviceSerial: deviceSerial,
    );
  }

  ///镜像翻转
  static Future<YsResponseEntity> ptzMirror(YsRequestEntity requestEntity) async {
    return await YsHttpApi.devPtzMirror(requestEntity);
  }

  ///开始录像
  static Future<bool> startRecordWithFile() async {
    return await _channel.invokeMethod('start_record');
  }

  ///停止录像
  static Future<bool> stopRecordWithFile() async {
    return await _channel.invokeMethod('stop_record');
  }

  // 释放资源
  static Future<void> dispose() async {
    await _channel.invokeMethod("dispose");
  }

  /// 无线配网模式
  /// mode: wifi-wifi配网 wave-声波配网
  static Future<void> startConfigWifi({
    required String deviceSerial,
    required String ssid,
    String? password,
    String? mode,
  }) async {
    await _channel.invokeMethod(
      "start_config_wifi",
      {
        'deviceSerial': deviceSerial,
        'ssid': ssid,
        'password': password,
        'mode': mode,
      },
    );
  }

  /// 热点配网模式
  static Future<void> startConfigAP({
    required String deviceSerial,
    required String ssid,
    String? password,
    String? verifyCode,
    String? routerName,
  }) async {
    await _channel.invokeMethod(
      "start_config_ap",
      {
        'deviceSerial': deviceSerial,
        'ssid': ssid,
        'password': password,
        'verifyCode': verifyCode,
        'routerName': routerName,
      },
    );
  }

  /// 停止配网
  static Future<bool> stopConfigPw({required String mode}) async {
    bool result = await _channel.invokeMethod('stop_config', {'mode': mode});
    return result;
  }

  /// 开始对讲
  static Future<bool> startVoiceTalk({
    required String deviceSerial,
    String? verifyCode,
    int cameraNo = 1,
    int isPhone2Dev = 1, //1手机端说设备端听 0手机端听设备端说
    int supportTalk = 1, //1-全双工 3-半双工
  }) async {
    Map<String, dynamic> argsParam = {
      "deviceSerial": deviceSerial,
      "verifyCode": verifyCode,
      "cameraNo": cameraNo,
      "isPhone2Dev": isPhone2Dev,
      "supportTalk": supportTalk,
    };
    bool result = await _channel.invokeMethod("start_voice_talk", argsParam);
    return result;
  }

  ///停止对讲
  static Future<bool> stopVoiceTalk() async {
    bool result = await _channel.invokeMethod("stop_voice_talk");
    return result;
  }
}
