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
                // ignore: empty_catches
              } catch (e) {}
            }
          }
        }
      },
    );
  }

  ///播放状态监听
  static void playerStatusListener(Function(YsPlayerStatus) onResult) {
    _playerStatus.setMessageHandler((message) async {
      if (message != null && message is String && message.isNotEmpty) {
        Map<String, dynamic> msg = json.decode(message);
        onResult(YsPlayerStatus.fromJson(msg));
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
  static Future<void> destoryLib() async {
    await _channel.invokeMethod("destoryLib");
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

  // 释放
  static Future<bool> videoRelease() async {
    await _channel.invokeMethod(
      "release",
    );
    return true;
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
  static Future<bool> startPlayback(YsViewRequestEntity ysViewRequestEntity) async {
    bool result = await _channel.invokeMethod("startPlayback", {
      'startTime': ysViewRequestEntity.startTime,
      'endTime': ysViewRequestEntity.endTime,
    });
    return result;
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

  static Future<int> getOSDTime() async {
    var result = await _channel.invokeMethod("getOSDTime");
    return result;
  }

  // 结束直播
  static Future<bool> endVideo() async {
    await _channel.invokeMethod("end");
    return true;
  }

  // 截屏
  static Future capturePicture() async {
    var result = await _channel.invokeMethod("capturePicture");
    return result;
  }

  /// 云台控制PTZ
  /// command:摄像头旋转方向 0-up 1-down 2-left 3-right 8-zoomin(镜头拉近) 9-zoomout(镜头拉远)
  /// action:0-开始 1-停止
  /// speed:旋转速度0-2 默认1
  static Future ptz({
    int ptzCommand = 0,
    int action = 0,
    int? speed = 1,
  }) async {
    await _channel.invokeMethod(
      "ptz",
      {
        'command': ptzCommand,
        'action': action,
        'speed': speed,
      },
    );
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
    await _channel.invokeMethod("release");
  }
}
