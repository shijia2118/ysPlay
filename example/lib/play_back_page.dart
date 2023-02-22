import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ys_play/ys.dart';
import 'package:ys_play_example/utils/permission_util.dart';
import 'package:ys_play_example/utils/time_util.dart';
import 'package:ys_play_example/widgets/time_selector.dart';
import 'package:ys_play_example/ys_player.dart';

import 'main.dart';

class PlaybackPage extends StatefulWidget {
  const PlaybackPage({Key? key}) : super(key: key);

  @override
  State<PlaybackPage> createState() => PlaybackPageState();
}

class PlaybackPageState extends State<PlaybackPage> {
  bool isRecording = false;
  late String startDt;
  late String endDt;

  int quarterTurns = 0;

  GlobalKey<YsPlayerState> ysPlayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    startDt = TimeUtil.date2Zero(now);
    endDt = TimeUtil.timeFormat(now.millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    String recordIcon = 'assets/icon_screen_record.png';
    if (isRecording) recordIcon = 'assets/icon_screen_record2.png';

    // 截屏和录屏按钮组
    Widget jplpWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onScreenShotHandle,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/icon_screen_shot.png',
              width: 30,
              height: 30,
            ),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: onScreenRecordHandle,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              recordIcon,
              width: 30,
              height: 30,
            ),
          ),
        ),
      ],
    );

    /// 开始时间
    Widget stWidget = TimeSelector(
      text: '开始时间',
      time: startDt,
      onSelected: (t) {
        startDt = t;
      },
    );

    /// 结束时间
    Widget etWidget = TimeSelector(
      text: '结束时间',
      time: endDt,
      onSelected: (t) {
        endDt = t;
      },
    );

    /// 回放按钮
    Widget playbackBtn = OutlinedButton(
      onPressed: onPlayback,
      child: Text('回放'),
    );

    return Scaffold(
      appBar: AppBar(title: Text('回放页面')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            YsPlayer(
              key: ysPlayKey,
              deviceSerial: deviceSerial,
              verifyCode: verifyCode,
              mediaType: YsMediaType.playback,
            ),

            // 截屏和录屏
            jplpWidget,

            SizedBox(height: 50),

            // 开始时间
            stWidget,

            SizedBox(height: 10),

            // 结束时间
            etWidget,
            SizedBox(height: 30),

            // 回放按钮
            playbackBtn,
          ],
        ),
      ),
    );
  }

  /// 截屏
  void onScreenShotHandle() async {
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

  /// 录屏
  void onScreenRecordHandle() async {
    PermissionUtils.storage(
      context,
      action: () async {
        if (isRecording) {
          bool result = await YsPlay.startRecordWithFile();
          if (result) {
            isRecording = false;
            showToast('录屏已结束,请到手机相册查看录制视频');
          }
        } else {
          bool result = await YsPlay.startRecordWithFile();
          if (result) {
            isRecording = true;
            showToast('录屏中...再次点击结束录屏');
          }
        }
        setState(() {});
      },
    );
  }

  /// 回放按钮点击事件
  void onPlayback() {
    if (ysPlayKey.currentState != null) {
      int st = TimeUtil.String2timeStamp(startDt);
      int et = TimeUtil.String2timeStamp(endDt);
      ysPlayKey.currentState!.onRePlay(startTime: st, endTime: et);
    }
  }
}
