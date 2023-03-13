import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ys_play/ys.dart';
import 'package:ys_play_example/real_page/intercom_btn.dart';
import 'package:ys_play_example/real_page/screen_record_btn.dart';

import '../main.dart';
import '../utils/permission_util.dart';
import '../ys_player/ys_player.dart';

class RealPage extends StatefulWidget {
  const RealPage({Key? key}) : super(key: key);

  @override
  State<RealPage> createState() => _RealPageState();
}

class _RealPageState extends State<RealPage> {
  bool isTalking = false;
  bool isLongPressed = false;
  int supportTalk = 0;
  late YsRequestEntity entity;
  bool showOtherUI = true;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> map = {
      'accessToken': accessToken,
      'deviceSerial': deviceSerial,
      'channelNo': cameraNo,
      'direction': 0,
      'speed': 1,
    };
    entity = YsRequestEntity.fromJson(map);
  }

  @override
  void dispose() {
    YsPlay.dispose();
    super.dispose();
  }

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
          onLeftTap: () => onPTZStart(direction: 2),
          onRightTap: () => onPTZStart(direction: 3),
          onTopTap: () => onPTZStart(direction: 0),
          onBottomTap: () => onPTZStart(direction: 1),
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
            onLongPressStart: (d) {
              onStartTalk(isPhone2Dev: 1);
            },
            onLongPressEnd: (d) {
              onStartTalk(isPhone2Dev: 0);
            },
            child: Image.asset(icon, width: 60, height: 60),
          ),
        ],
      );
    }

    YsPlayer ysPlayer = YsPlayer(
      deviceSerial: deviceSerial,
      verifyCode: verifyCode,
      mediaType: YsMediaType.real,
      showOtherUI: (show) {
        setState(() {
          showOtherUI = show;
        });
      },
    );

    return showOtherUI
        ? Scaffold(
            appBar: AppBar(
              title: Text('直播页面'),
            ),
            body: Column(
              children: [
                ysPlayer,
                buttonBars,
                Expanded(child: bodyWidget),
              ],
            ),
          )
        : Scaffold(body: ysPlayer);
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
    entity.command = 2;
    await YsPlay.ptzMirror(entity).then((value) {
      if (value.code != '200') {
        showToast(value.msg ?? '未知异常');
      }
    });
  }

  /**
   * 云台控制 参数列表:
   * 1.accessToken,
   * 2.deviceSerial,
   * 3.channelNo(cameraNo),
   * 4.direction:0-上，1-下，2-左，3-右，4-左上，5-左下，6-右上，7-右下，8-放大，9-缩小，
   *             10-近焦距，11-远焦距
   * 5.speed:0-慢，1-适中，2-快，海康设备参数不可为0.默认为1
   */
  void onPTZStart({required int direction}) async {
    entity.direction = direction;
    //开始云台控制之后必须先调用停止云台控制接口才能进行其他操作，包括其他方向的云台转动
    bool result = await onPTZCancel();
    if (result) {
      await YsPlay.ptzStart(
        deviceSerial: deviceSerial,
        channelNo: cameraNo,
        accessToken: accessToken,
        direction: entity.direction!,
      ).then((value) {
        if (value.code != '200') {
          showToast(value.msg ?? '未知异常');
        }
      });
    }
  }

  /// 摄像头停止旋转
  Future<bool> onPTZCancel() async {
    bool result = false;
    await YsPlay.ptzStop(
      accessToken: accessToken,
      deviceSerial: deviceSerial,
      channelNo: cameraNo,
      direction: entity.direction,
    ).then((value) {
      if (value.code == '200') {
        result = true;
      } else {
        showToast(value.msg ?? '未知异常');
        result = false;
      }
    });
    return result;
  }

  /// 抓拍
  /// 内部icon点击事件，抓拍后发送自己的到服务器
  void onInnerIconClicked() {}

  /// 对讲
  void onIntercom(bool isTalking) async {
    setState(() {
      this.isTalking = isTalking;
    });

    if (isTalking) {
      // 判断是否支持对讲
      await YsPlay.getDevCapacity(
              accessToken: accessToken, deviceSerial: deviceSerial)
          .then((res) {
        if (res.code == '200' && res.data != null) {
          //1-全双工 3-半双工
          if (res.data!.supportTalk == "1" || res.data!.supportTalk == "3") {
            supportTalk = int.parse(res.data!.supportTalk!);
          } else {
            showToast('该设备不支持对讲');
            supportTalk = 0;
          }
        } else {
          showToast(res.msg ?? '未知异常');
          supportTalk = 0;
        }
      });
    } else {
      isLongPressed = false;
      await YsPlay.stopVoiceTalk();
    }
  }

  /// 长按说话
  void onStartTalk({required isPhone2Dev}) async {
    setState(() {
      isLongPressed = isPhone2Dev == 1;
    });
    // 请求麦克风权限
    PermissionUtils.microPhone(
      context,
      action: () async {
        await YsPlay.startVoiceTalk(
          deviceSerial: deviceSerial,
          verifyCode: verifyCode,
          isPhone2Dev: isPhone2Dev,
          supportTalk: supportTalk,
        );
      },
    );
  }
}
