import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ys_play/ys.dart';
import 'package:ys_play_example/real_page/intercom_btn.dart';
import 'package:ys_play_example/real_page/screen_record_btn.dart';

import '../main.dart';
import '../utils/permission_util.dart';
import '../ys_player.dart';

class RealPage extends StatefulWidget {
  const RealPage({Key? key}) : super(key: key);

  @override
  State<RealPage> createState() => _RealPageState();
}

class _RealPageState extends State<RealPage> {
  int ptzCommand = 0;

  bool isTalking = false;
  bool isLongPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget innerWidget = Image.asset(
      'assets/camera.png',
      width: 42,
      height: 42,
    );

    /// 一组操作按钮
    Widget buttonBars = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: capturePicture,
          icon: Image.asset('assets/icon_screen_shot.png'),
        ),
        const ScreenRecordBtn(),
        IntercomBtn(
          onIntercom: (isTalking) => onIntercom(isTalking),
        ),
        IconButton(
          onPressed: onMirrorReverse,
          icon: Image.asset('assets/icon_turn_over.png'),
        ),
      ],
    );

    /// 主体部分：对讲时显示对讲组件；否则显示控制盘
    Widget bodyWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        PanelView(
          onLeftTap: onLeftTapHandle,
          onRightTap: onRightTapHandle,
          onTopTap: onTopTapHandle,
          onBottomTap: onBottomTapHandle,
          innerIcon: innerWidget,
          onCanceled: onPTZCancel,
          onInnerIconClicked: onInnerIconClicked,
        ),
        SizedBox(height: 30),
        Text('说明：长按方向键进行镜头移动，取消按键停止'),
      ],
    );

    if (isTalking) {
      String icon = 'assets/icon_talk.png';
      String text = '长按说话，松开收听';
      if (isLongPressed) {
        icon = 'assets/icon_talk_select.png';
        text = '对讲中...';
      }

      bodyWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(text),
          SizedBox(height: 20),
          GestureDetector(
            onLongPress: onLongPress,
            onLongPressUp: onLongPressUp,
            child: Image.asset(icon, width: 60, height: 60),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('直播页面'),
      ),
      body: Column(
        children: [
          YsPlayer(
            deviceSerial: deviceSerial,
            verifyCode: verifyCode,
            mediaType: JkMediaType.real,
          ),
          buttonBars,
          Expanded(child: bodyWidget),
        ],
      ),
    );
  }

  /// 截屏
  void capturePicture() async {
    PermissionUtils.storage(
      context,
      action: () async {
        bool result = await YsPlay.capturePicture();
        if (result) {
          showToast('截屏已保存到手机相册，请到手机相册查看');
        } else {
          showToast('截屏失败');
        }
      },
    );
  }

  /// 屏幕翻转
  void onMirrorReverse() async {
    showToast('需要调用服务端接口实现');
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

  /// 对讲
  void onIntercom(bool isTalking) async {
    setState(() {
      this.isTalking = isTalking;
    });
    if (!isTalking) isLongPressed = false;
  }

  /// 长按说话
  void onLongPress() async {
    // 判断是否支持对讲
    bool result = await YsPlay.isSupportTalk(deviceSerial: deviceSerial);
    if (result) {
      setState(() {
        isLongPressed = true;
      });

      // 请求麦克风权限
      PermissionUtils.microPhone(
        context,
        action: () async {
          await YsPlay.startVoiceTalk(
            deviceSerial: deviceSerial,
            verifyCode: verifyCode,
            isTalk: !isLongPressed,
          );
        },
      );
    }
  }

  /// 松开收听
  void onLongPressUp() async {
    setState(() {
      isLongPressed = false;
    });
  }
}
