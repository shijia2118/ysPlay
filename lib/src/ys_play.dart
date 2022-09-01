import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ys_play/src/entity/ys_player_status.dart';
import 'package:ys_play/ys.dart';

class YsPlay {
  static const _channel = MethodChannel("com.example.ys_play");

  static const BasicMessageChannel<dynamic> _nativeYs =
      BasicMessageChannel("com.example.ys_play/record_file", StandardMessageCodec());

  static const BasicMessageChannel<dynamic> _playerStatus =
  BasicMessageChannel("com.example.ys_play/player_status", StandardMessageCodec());

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
              } catch (e) {
                print('ys_play error: $e');
              }
            }
          }
        }
      },
    );
  }

  ///播放状态
  static void playerStatusListener(Function(YsPlayerStatus) onResult){
    _playerStatus.setMessageHandler((message)async {
      if(message!=null&&message is String &&message.isNotEmpty){
        Map<String, dynamic> msg = json.decode(message);
        print('>>>>>>msg===$msg');
        onResult(YsPlayerStatus.fromJson(msg));
      }
    });
  }

  //  *  @param appKey 账号appKey
  static Future<bool> initSdk(String appKey) async {
    YsPlay.initMessageHandler();
    await _channel.invokeMethod("init_sdk", {
      'appKey': appKey,
    });
    return true;
  }

  static Future<bool> destoryLib() async {
    await _channel.invokeMethod("destoryLib");
    return true;
  }

  // 设置 accessToken
  static Future<bool> setAccessToken(String accessToken) async {
    bool result = await _channel.invokeMethod("set_access_token", {
      'accessToken': accessToken,
    });
    return result;
  }

  // 初始化播放器
  static Future<bool> initEZPlayer(String deviceSerial, String verifyCode, int cameraNo,{required Function(YsPlayerStatus) playerStatus}) async {
    YsPlay.playerStatusListener(playerStatus);
    bool result = await _channel.invokeMethod("EZPlayer_init", {
      'deviceSerial': deviceSerial,
      'verifyCode': verifyCode,
      'cameraNo': cameraNo,
    });
    return result;
  }

  // 释放
  static Future<bool> videoRelease() async {
    await _channel.invokeMethod(
      "release",
    );
    return true;
  }

  // 开启声音
  static Future<bool> closeSound() async {
    await _channel.invokeMethod("sound", {
      'Sound': false,
    });
    return true;
  }

  // 关闭声音
  static Future<bool> openSound() async {
    await _channel.invokeMethod("sound", {
      'Sound': true,
    });
    return true;
  }

  static Future<bool> startRealPlay() async {
    await _channel.invokeMethod("startRealPlay");
    return true;
  }

  static Future<bool> stopRealPlay() async {
    await _channel.invokeMethod("stopRealPlay");
    return true;
  }

  static Future<int> getOSDTime() async {
    var result = await _channel.invokeMethod("getOSDTime");
    return result;
  }

  // 结束直播
  static Future<bool> endVideo() async {
    await _channel.invokeMethod("end");
    return true;
  }

  // 开始回放
  static Future<bool> startPlayback(YsViewRequestEntity ysViewRequestEntity) async {
    await _channel.invokeMethod("startPlayback", {
      'startTime': ysViewRequestEntity.startTime,
      'endTime': ysViewRequestEntity.endTime,
    });
    return true;
  }

  // 停止回放
  static Future<bool> stopPlayback() async {
    await _channel.invokeMethod("stopPlayback");
    return true;
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
}
