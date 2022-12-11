import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ys_play/ys.dart';
import 'package:ys_play_example/land_scape_page.dart';
import 'package:ys_play_example/widgets/player_forground_widget.dart';

import 'widgets/bottom_handle_bar.dart';
import 'main.dart';

enum JkMediaType {
  playback,
  real,
}

class YsPlayer extends StatefulWidget {
  final String deviceSerial;
  final String verifyCode;
  final int cameraNo;
  final JkMediaType mediaType;
  final Orientation orientation;
  const YsPlayer({
    Key? key,
    required this.deviceSerial,
    required this.verifyCode,
    this.cameraNo = 1,
    this.mediaType = JkMediaType.playback,
    this.orientation = Orientation.portrait,
  }) : super(key: key);

  @override
  State<YsPlayer> createState() => YsPlayerState();
}

class YsPlayerState extends State<YsPlayer> {
  late String deviceSerial;
  late String verifyCode;
  late int cameraNo;
  late JkMediaType mediaType;
  late double playerHeight;
  late double playerWidth;

  bool isPlayerSuccess = false;

  String? errorInfo; //播放错误提示

  late Orientation orientation;

  @override
  void initState() {
    super.initState();
    initParams();
    if (orientation == Orientation.portrait) {
      prepareYsPlayer();
    } else {
      isPlayerSuccess = true;
    }

    /// 播放结果监听
    YsPlay.onResultListener((status) async {
      if (status.isSuccess == true) {
        isPlayerSuccess = true;
        if (mounted) setState(() {});
      } else {
        //播放错误
        if (status.playErrorInfo != null) {
          errorInfo = status.playErrorInfo;
          if (mounted) setState(() {});
        }
        //对讲错误
        if (status.talkErrorInfo != null) {
          showToast(status.talkErrorInfo!);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (orientation == Orientation.portrait) videoDispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    playerHeight = orientation == Orientation.portrait ? 200 : size.height;
    playerWidth = size.width;
    return Container(
      width: playerWidth,
      height: playerHeight,
      color: Colors.black,
      child: Stack(
        children: [
          //底层播放视图
          const YsPlayView(),
          GestureDetector(
            onTap: () {
              setState(() {});
            },
            child: Container(
              height: playerHeight,
              width: playerWidth,
              color: Colors.transparent,
            ),
          ),
          //底部操作按钮组
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomHandleBar(
              width: playerWidth,
              height: 35,
              isPrepared: isPlayerSuccess,
              onPlayHandle: (isPlaying) => onPlayHandle(isPlaying),
              onFullScreenHandle: onFullScreenHandle,
              onSoundHandle: (isOpen) => onSoundHandle(isOpen),
              onSelectLevelHandle: (i) => onSelectLevelHandle(i),
              mediaType: mediaType,
              orientation: orientation,
            ),
          ),
          //视图上层加载指示器
          PlayerForgroundWidget(
            errorInfo: errorInfo,
            isVisible: !isPlayerSuccess,
            onRePlay: onRePlay,
          ),
        ],
      ),
    );
  }

  ///初始化参数
  void initParams() {
    deviceSerial = widget.deviceSerial;
    verifyCode = widget.verifyCode;
    cameraNo = widget.cameraNo;
    mediaType = widget.mediaType;
    orientation = widget.orientation;
  }

  ///播放前准备
  Future<void> prepareYsPlayer() async {
    // 1.从服务端获取accessToken
    // 这里直接使用静态token，具体项目中需要从接口获取
    // 2.拿到accessToken后，绑定账号和设备
    bool tokenResult = await YsPlay.setAccessToken(accessToken);
    if (tokenResult) {
      // 3.注册播放器
      await YsPlay.initEZPlayer(
        deviceSerial,
        verifyCode,
        cameraNo,
      ).then((value) async {
        if (value) {
          // 4.开始播放
          await start2Play();
        }
      });
    }
  }

  ///开始播放
  Future<bool> start2Play({
    int? startTime,
    int? endTime,
  }) async {
    if (mediaType == JkMediaType.playback) {
      DateTime now = DateTime.now();
      int et = now.millisecondsSinceEpoch;
      int st = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      startTime ??= st;
      endTime ??= et;
      // 回放
      return await YsPlay.startPlayback(
        startTime,
        endTime,
      );
    } else if (mediaType == JkMediaType.real) {
      // 直播
      return await YsPlay.startRealPlay();
    } else {
      return false;
    }
  }

  /// 发生异常时，点击重播
  void onRePlay({
    int? startTime,
    int? endTime,
  }) async {
    setState(() {
      errorInfo = null;
      isPlayerSuccess = false;
    });
    await start2Play(startTime: startTime, endTime: endTime);
  }

  /// 停止播放，释放资源
  void videoDispose() async {
    if (mediaType == JkMediaType.playback) {
      await YsPlay.stopPlayback();
    } else if (mediaType == JkMediaType.real) {
      await YsPlay.stopRealPlay();
    }
    await YsPlay.dispose();
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
  void onPlayHandle(bool isPlaying) async {
    if (mediaType == JkMediaType.playback) {
      isPlaying ? resumePlayback() : pausePlayback();
    } else if (mediaType == JkMediaType.real) {
      isPlaying ? onRePlay() : YsPlay.stopRealPlay();
    }
  }

  /// 点击声音按钮
  void onSoundHandle(bool isOpen) async {
    isOpen ? await YsPlay.openSound() : await YsPlay.closeSound();
  }

  /// 设置清晰度
  void onSelectLevelHandle(int i) async {
    if (mediaType == JkMediaType.real) {
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

  /// 点击全屏按钮
  void onFullScreenHandle() {
    // 竖屏到横屏
    if (orientation == Orientation.portrait) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LandscapePage(mediaType: mediaType),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
