import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ys_play_example/ys_player.dart';

import 'main.dart';

class LandscapePage extends StatefulWidget {
  final JkMediaType mediaType;
  const LandscapePage({
    super.key,
    this.mediaType = JkMediaType.playback,
  });

  @override
  State<LandscapePage> createState() => _LandscapePageState();
}

class _LandscapePageState extends State<LandscapePage> {
  late JkMediaType mediaType;

  @override
  void initState() {
    super.initState();
    //全屏时旋转方向，左边
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []); //隐藏状态栏，底部按钮栏
    initParams();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); //显示状态栏、底部按钮栏

    //页面销毁时执行还原操作
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YsPlayer(
        deviceSerial: deviceSerial,
        verifyCode: verifyCode,
        mediaType: mediaType,
        orientation: Orientation.landscape,
      ),
    );
  }

  /// 初始化参数
  void initParams() {
    mediaType = widget.mediaType;
  }
}
