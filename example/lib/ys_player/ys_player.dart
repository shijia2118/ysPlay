import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ys_play/ys_play.dart';
import 'package:ys_play_example/ys_player/ys_player_land_scape.dart';
import 'package:ys_play_example/ys_player/ys_player_portrait.dart';

import '../main.dart';

class YsPlayer extends StatefulWidget {
  final String deviceSerial;
  final String verifyCode;
  final int cameraNo;
  final YsMediaType mediaType;
  final Function(bool)? showOtherUI;
  const YsPlayer({
    Key? key,
    required this.deviceSerial,
    required this.verifyCode,
    this.cameraNo = 1,
    this.mediaType = YsMediaType.playback,
    this.showOtherUI,
  }) : super(key: key);

  @override
  State<YsPlayer> createState() => YsPlayerState();
}

class YsPlayerState extends State<YsPlayer> {
  late String deviceSerial;
  late String verifyCode;
  late int cameraNo;
  late YsMediaType mediaType;
  late double height;
  late double width;

  YsPlayStatus ysPlayStatus = YsPlayStatus.onPrepareing;

  String? errorInfo; //播放错误提示

  bool get isFullScreen =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  @override
  void initState() {
    super.initState();
    initParams();
    setAccessToken();

    /// 播放结果监听
    YsPlay.onResultListener(
      onSuccess: () {
        ysPlayStatus = YsPlayStatus.onPlaying;
        if (mounted) setState(() {});
      },
      onPlayError: (errorInfo) {
        this.errorInfo = errorInfo;
        ysPlayStatus = YsPlayStatus.onError;
        if (mounted) setState(() {});
      },
      onTalkError: (errorInfo) {
        showToast(errorInfo);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    YsPlay.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    height = isFullScreen ? size.height : 200;
    width = size.width;
    return Container(
      width: width,
      height: height,
      color: Colors.black,
      child: isFullScreen
          ? YsPlayerLandscape(
              width: width,
              height: height,
              errorInfo: errorInfo,
              onFullScreenHandle: onFullScreenHandle,
              onPlayHandle: onPlayHandle,
              onSoundHandle: onSoundHandle,
              onScreenTouched: onScreenTouched,
              onSelectLevelHandle: onSelectLevelHandle,
              onRePlay: onRePlay,
              ysPlayStatus: ysPlayStatus,
              mediaType: mediaType,
            )
          : YsPlayerPortrait(
              width: width,
              height: height,
              errorInfo: errorInfo,
              onFullScreenHandle: onFullScreenHandle,
              onPlayHandle: onPlayHandle,
              onSoundHandle: onSoundHandle,
              onScreenTouched: onScreenTouched,
              onSelectLevelHandle: onSelectLevelHandle,
              onRePlay: onRePlay,
              ysPlayStatus: ysPlayStatus,
              mediaType: mediaType,
            ),
    );
  }

  ///初始化参数
  void initParams() {
    deviceSerial = widget.deviceSerial;
    verifyCode = widget.verifyCode;
    cameraNo = widget.cameraNo;
    mediaType = widget.mediaType;
  }

  /// 获取并设置"accessToken"
  /// "accessToken"一般从服务器端获取,这里为了便利，直接定义成了全局变量。
  /// 拿到"accessToken"后,传给萤石SDK，实现授权登录。
  /// 否则无法继续回放，直播，对讲等操作。
  Future<void> setAccessToken() async {
    bool tokenResult = await YsPlay.setAccessToken(accessToken);
    if (tokenResult) {
      // 开始播放
      await startPlay();
    }
  }

  /// 开始播放
  /// 播放有2种类型：直播和回放。它有一个自定义的枚举类 [YsMediaType]:
  /// [YsMediaType.playback] : 回放;
  /// [YsMediaType.real] : 直播。
  /// * 如果是直播，需要传以下3个参数:
  ///   1.`deviceSerial`:设备序列号,一般通过扫描设备二维码获得,必传;
  ///   2.`verifyCode`:如果视频需要加密，可以传;默认为设备的6位验证码.
  ///   3.`cameraNo`:设备通道号，默认为1，可不传.
  /// * 如果是回放，除了上述3个参数外，还有2个必传参数:
  ///   1.`startTime`:开始时间;
  ///   2.`endTime`:结束时间。
  Future<bool> startPlay({
    int? startTime,
    int? endTime,
  }) async {
    // 回放
    if (mediaType == YsMediaType.playback) {
      DateTime now = DateTime.now();
      int et = now.millisecondsSinceEpoch;
      int st = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      startTime ??= st;
      endTime ??= et;
      return await YsPlay.startPlayback(
        deviceSerial: deviceSerial,
        startTime: startTime,
        endTime: endTime,
        verifyCode: verifyCode,
        cameraNo: cameraNo,
      );
    } else if (mediaType == YsMediaType.real) {
      // 直播
      return await YsPlay.startRealPlay(
        deviceSerial: deviceSerial,
        verifyCode: verifyCode,
        cameraNo: cameraNo,
      );
    } else {
      return false;
    }
  }

  /// 停止直播
  Future<bool> stopRealPlay() async {
    return await YsPlay.stopRealPlay();
  }

  /// 发生异常时，点击重播
  void onRePlay({
    int? startTime,
    int? endTime,
  }) async {
    errorInfo = null;
    ysPlayStatus = YsPlayStatus.onPrepareing;
    if (mounted) setState(() {});
    await startPlay(startTime: startTime, endTime: endTime);
  }

  /// 暂停回放
  void pausePlayback() async {
    await YsPlay.pausePlayback();
  }

  /// 恢复回放
  void resumePlayback() async {
    await YsPlay.resumePlayback();
  }

  /// 点击播放按钮
  void onPlayHandle(YsPlayStatus playStatus) async {
    if (playStatus == YsPlayStatus.onPlaying) {
      if (mediaType == YsMediaType.playback) {
        resumePlayback();
      } else if (mediaType == YsMediaType.real) {
        onRePlay();
      }
    } else if (playStatus == YsPlayStatus.onStop) {
      if (mediaType == YsMediaType.playback) {
        pausePlayback();
      } else if (mediaType == YsMediaType.real) {
        YsPlay.stopRealPlay();
      }
    }
    this.ysPlayStatus = playStatus;
    if (mounted) setState(() {});
  }

  /// 点击声音按钮
  void onSoundHandle(bool isOpen) async {
    isOpen ? await YsPlay.openSound() : await YsPlay.closeSound();
  }

  /// 设置清晰度
  void onSelectLevelHandle(int i) async {
    if (mediaType == YsMediaType.real) {
      bool result = await YsPlay.setVideoLevel(
        deviceSerial: deviceSerial,
        videoLevel: i,
      );
      if (result) {
        // 关闭直播
        await YsPlay.stopRealPlay();
        // 打开直播
        onRePlay();
      }
    }
  }

  /// 视频播放区域触摸事件
  void onScreenTouched() {
    if (mounted) setState(() {});
  }

  /// 点击全屏按钮
  void onFullScreenHandle() async {
    if (isFullScreen) {
      //横屏到竖屏
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      //显示状态栏、底部按钮栏
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);

      //回调给父组件，显示其他组件
      Future.delayed(const Duration(milliseconds: 100), () {
        if (widget.showOtherUI != null) {
          widget.showOtherUI!(true);
        }
      });
    } else {
      //回调给父组件，隐藏其他组件
      // if (widget.showOtherUI != null) {
      //   widget.showOtherUI!(false);
      // }
      // 竖屏到横屏
      DeviceOrientation deviceOrientation = DeviceOrientation.landscapeLeft;
      if (Platform.isIOS) {
        deviceOrientation = DeviceOrientation.landscapeRight;
      }
      await SystemChrome.setPreferredOrientations([deviceOrientation]);
      //隐藏状态栏，底部按钮栏
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: []);

      //回调给父组件，隐藏其他组件
      Future.delayed(const Duration(milliseconds: 100), () {
        if (widget.showOtherUI != null) {
          widget.showOtherUI!(false);
        }
      });
    }
  }
}
