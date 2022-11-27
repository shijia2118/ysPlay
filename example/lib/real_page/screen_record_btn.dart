import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ys_play/ys.dart';

import '../../../../utils/permission_util.dart';

class ScreenRecordBtn extends StatefulWidget {
  const ScreenRecordBtn({super.key});

  @override
  State<ScreenRecordBtn> createState() => _ScreenRecordBtnState();
}

class _ScreenRecordBtnState extends State<ScreenRecordBtn> {
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    String recordIcon = 'assets/icon_screen_record.png';
    if (isRecording) recordIcon = 'assets/icon_screen_record2.png';

    return IconButton(
      onPressed: onScreenRecordHandle,
      icon: Image.asset(recordIcon),
    );
  }

  /// 录屏
  void onScreenRecordHandle() async {
    PermissionUtils.storage(
      context,
      action: () async {
        if (isRecording) {
          bool result = await YsPlay.stopRecordWithFile();
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
}
