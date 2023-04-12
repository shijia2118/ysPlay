import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ys_play/src/entity/capacity_response_entity.dart';
import 'package:ys_play/src/entity/ys_player_status.dart';
import 'package:ys_play/src/entity/ys_pw_result.dart';
import 'package:ys_play/src/entity/ys_request_entity.dart';
import 'package:ys_play/src/entity/ys_response_entity.dart';
import 'package:ys_play/src/ys_http_api.dart';

enum YsMediaType {
  playback, //回放
  real, //直播
}

/// 播放状态
enum YsPlayStatus {
  onPrepareing,
  onPlaying,
  onStop,
  onError;
}

class YsPlay {
  /// 平台通信渠道
  static const _channel = MethodChannel("com.example.ys_play");

  /// 播放状态渠道
  static const BasicMessageChannel<dynamic> _playerStatus = BasicMessageChannel(
      "com.example.ys_play/player_status", StandardMessageCodec());

  /// 配网结果渠道
  static const BasicMessageChannel<dynamic> _pwResultChannel =
      BasicMessageChannel(
          "com.example.ys_play/pei_wang", StandardMessageCodec());

  /// 播放状态监听
  static void onResultListener({
    required Function() onSuccess,
    required Function(String errorInfo) onPlayError,
    required Function(String errorInfo) onTalkError,
  }) {
    _playerStatus.setMessageHandler((message) async {
      if (message != null && message is String && message.isNotEmpty) {
        Map<String, dynamic> map = json.decode(message);
        YsPlayerStatus status = YsPlayerStatus.fromJson(map);
        if (status.isSuccess == true) {
          onSuccess();
        } else if (status.playErrorInfo != null) {
          onPlayError(status.playErrorInfo!);
        } else if (status.talkErrorInfo != null) {
          onTalkError(status.talkErrorInfo!);
        }
      }
    });
  }

  /// 配网结果监听
  static void peiwangResultListener(Function(YsPwResult) onResult) {
    _pwResultChannel.setMessageHandler((message) async {
      if (message != null && message is String && message.isNotEmpty) {
        Map<String, dynamic> msg = json.decode(message);
        onResult(YsPwResult.fromJson(msg));
      }
    });
  }

  /// 初始化萤石SDK
  /// 唯一一个必传参数:`appKey`.在萤石SDK官方平台中创建应用后生成。
  static Future<bool> initSdk(String appKey) async {
    bool result = await _channel.invokeMethod("init_sdk", {'appKey': appKey});
    return result;
  }

  /// 设置`accessToken`
  /// 访问令牌，由服务器返回给客户端，用于认证。
  static Future<bool> setAccessToken(String accessToken) async {
    bool result = await _channel
        .invokeMethod("set_access_token", {'accessToken': accessToken});
    return result;
  }

  /// 开始回放
  ///
  /// 有5个入参:
  /// * 其中有3个必传参数:
  ///   1.`deviceSerial`:设备序列号,一般通过扫描设备二维码获得,必传;
  ///   2.`startTime`:开始时间;
  ///   3.`endTime`:结束时间。
  /// * 2个可选参数:
  ///   1.`verifyCode`:如果视频需要加密，可以传;默认为设备的6位验证码;
  ///   2.`cameraNo`:设备通道号，默认为1，可不传.
  static Future<bool> startPlayback({
    required String deviceSerial,
    required int startTime,
    required int endTime,
    String? verifyCode,
    int? cameraNo,
  }) async {
    bool result = await _channel.invokeMethod("startPlayback", {
      'deviceSerial': deviceSerial,
      'startTime': startTime,
      'endTime': endTime,
      'verifyCode': verifyCode,
      'cameraNo': cameraNo,
    });
    return result;
  }

  /// 停止回放
  static Future<bool> stopPlayback() async {
    await _channel.invokeMethod("stopPlayback");
    return true;
  }

  /// 暂停回放
  static Future<bool> pausePlayback() async {
    bool result = await _channel.invokeMethod("pause_play_back");
    return result;
  }

  /// 恢复回放
  static Future<bool> resumePlayback() async {
    bool result = await _channel.invokeMethod("resume_play_back");
    return result;
  }

  /// 开始直播
  ///
  /// 有3个入参:
  /// 其中`deviceSerial`必传,`verifyCode`和`cameraNo`可选。
  static Future<bool> startRealPlay({
    required String deviceSerial,
    String? verifyCode,
    int? cameraNo,
  }) async {
    return await _channel.invokeMethod("startRealPlay", {
      'deviceSerial': deviceSerial,
      'verifyCode': verifyCode,
      'cameraNo': cameraNo,
    });
  }

  /// 停止直播
  static Future<bool> stopRealPlay() async {
    await _channel.invokeMethod("stopRealPlay");
    return true;
  }

  /// 打开声音
  static Future<bool> openSound() async {
    bool result = await _channel.invokeMethod("openSound");
    return result;
  }

  /// 关闭声音
  static Future<bool> closeSound() async {
    bool result = await _channel.invokeMethod("closeSound");
    return result;
  }

  /// 截屏
  static Future capturePicture() async {
    var result = await _channel.invokeMethod("capturePicture");
    return result;
  }

  /// 开始录像
  static Future<bool> startRecordWithFile() async {
    return await _channel.invokeMethod('start_record');
  }

  /// 停止录像
  static Future<bool> stopRecordWithFile() async {
    return await _channel.invokeMethod('stop_record');
  }

  /// 设置视频清晰度
  ///
  /// `deviceSerial`:设备序列号,一般通过扫描设备二维码获得,必传;
  /// `cameraNo`:设备通道号，默认为1，可不传;
  /// `videoLevel`:  0-流畅 1-均衡 2-高品质,默认传2.
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

  /// 控制云台 开始
  ///
  /// `accessToken`:访问令牌，由服务器返回给客户端，用于认证;
  /// `deviceSerial`:设备序列号,一般通过扫描设备二维码获得,必传;
  /// `cameraNo`:设备通道号，默认为1，可不传;
  /// `direction`:0-上，1-下，2-左，3-右，4-左上，5-左下，6-右上，7-右下，8-放大，9-缩小，
  ///            10-近焦距，11-远焦距;
  /// `speed`:0-慢，1-适中，2-快，海康设备参数不可为0.默认为1.
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

  /// 云台控制 停止
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

  /// 获取设备能力集
  static Future<CapacityResponseEntity> getDevCapacity({
    required String accessToken,
    required String deviceSerial,
  }) async {
    return await YsHttpApi.getDevCapacity(
      accessToken: accessToken,
      deviceSerial: deviceSerial,
    );
  }

  /// 镜像翻转
  static Future<YsResponseEntity> ptzMirror(
      YsRequestEntity requestEntity) async {
    return await YsHttpApi.devPtzMirror(requestEntity);
  }

  /// 释放资源
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

  /// 获取存储介质状态(如是否初始化，格式化进度等)
  static Future getStorageStatus({required String deviceSerial}) async {
    return await _channel
        .invokeMethod("get_storage_status", {'deviceSerial': deviceSerial});
  }

  /// 根据分区编号格式化
  static Future formatStorage({
    required String deviceSerial,
    int? index,
  }) async {
    return await _channel.invokeMethod("format_storage", {
      'deviceSerial': deviceSerial,
      'partitionIndex': index,
    });
  }
}
