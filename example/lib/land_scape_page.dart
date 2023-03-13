import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ys_play_example/ys_player.dart';

import 'main.dart';

class LandscapePage extends StatefulWidget {
  final YsMediaType mediaType;
  const LandscapePage({
    super.key,
    this.mediaType = YsMediaType.playback,
  });

  @override
  State<LandscapePage> createState() => _LandscapePageState();
}

class _LandscapePageState extends State<LandscapePage> {
  late YsMediaType mediaType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        print('>>>>>>组件渲染完成');

        //全屏时旋转方向，左边
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: []); //隐藏状态栏，底部按钮栏
      },
    );
    initParams();
  }

  @override
  Widget build(BuildContext context) {
    print('>>>>>>build');

    return WillPopScope(
      child: Scaffold(
        body: YsPlayer(
          deviceSerial: deviceSerial,
          verifyCode: verifyCode,
          mediaType: mediaType,
        ),
      ),
      onWillPop: () async {
        //显示状态栏、底部按钮栏
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);

        //横屏到竖屏
        await SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp]);
        return true;
      },
    );
  }

  /// 初始化参数
  void initParams() {
    mediaType = widget.mediaType;
  }
}
