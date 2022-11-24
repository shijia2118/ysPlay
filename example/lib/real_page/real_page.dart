import 'package:flutter/material.dart';
import 'package:ys_play/ys.dart';

import '../main.dart';
import '../ys_player.dart';

class RealPage extends StatefulWidget {
  const RealPage({Key? key}) : super(key: key);

  @override
  State<RealPage> createState() => _RealPageState();
}

class _RealPageState extends State<RealPage> {
  int ptzCommand = 0;

  @override
  Widget build(BuildContext context) {
    Widget innerWidget = Image.asset(
      'assets/camera.png',
      width: 42,
      height: 42,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('直播页面'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            YsPlayer(
              deviceSerial: deviceSerial,
              verifyCode: verifyCode,
              mediaType: JkMediaType.real,
            ),
            SizedBox(height: 50),
            PanelView(
              onLeftTap: onLeftTapHandle,
              onRightTap: onRightTapHandle,
              onTopTap: onTopTapHandle,
              onBottomTap: onBottomTapHandle,
              innerIcon: innerWidget,
              onCanceled: onPTZCancel,
              onInnerIconClicked: onInnerIconClicked,
            ),
          ],
        ),
      ),
    );
  }

  /// 摄像头往左
  void onLeftTapHandle() async {
    ptzCommand = 2;
    await YsPlay.ptz(ptzCommand: ptzCommand);
  }

  /// 摄像头往右
  void onRightTapHandle() async {
    ptzCommand = 3;
    await YsPlay.ptz(ptzCommand: ptzCommand);
  }

  /// 摄像头向上
  void onTopTapHandle() async {
    ptzCommand = 0;
    await YsPlay.ptz(ptzCommand: ptzCommand);
  }

  /// 摄像头向下
  void onBottomTapHandle() async {
    ptzCommand = 1;
    await YsPlay.ptz(ptzCommand: ptzCommand);
  }

  /// 摄像头停止旋转
  void onPTZCancel() async {
    await YsPlay.ptz(ptzCommand: ptzCommand, action: 1);
  }

  /// 内部icon点击事件
  void onInnerIconClicked() {}
}
