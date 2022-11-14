import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ys_play/ys.dart';
import 'package:ys_play_example/home_page.dart';
import 'package:ys_play_example/utils/permission_util.dart';

String appKey = '9ddc4fb7c0ef4996b04dd90156368f7c';
String accessToken = 'ra.224hfunx4gs9km8y1kbi677pbdphb2sm-7lj7onkd3y-019kxqt-huo1x5v7i';
String deviceSerial = 'C63167422';
String verifyCode = 'PDSWCZ';
int cameraNo = 1;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> btnList = [
    '初始化SDK',
    '绑定token',
    '注册播放器',
    '开始回放',
    '停止回放',
    '',
    '开始直播',
    '停止直播',
    '',
    '打开音量',
    '关闭音量',
    '截屏',
    '向左旋转',
    '向右旋转',
    '向上旋转',
    '向下旋转',
    '镜头拉近',
    '镜头拉远',
    '云台停止',
    "",
    "",
    "开始录像",
    "停止录像",
  ];

  Map<String, dynamic> creationParams = {
    'deviceSerial': deviceSerial,
    'verifyCode': verifyCode,
    'cameraNo': cameraNo,
  };

  /// 是否开始播放
  /// 播放前，显示加载指示器
  bool isPlayerStarted = false;

  /// 云台控制 旋转方向,默认向上
  int command = 0;

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }

  ///按钮点击事件
  void itemClickedHandle(String text) {
    switch (text) {
      case '初始化SDK':
        initSDK();
        break;
      case '绑定token':
        setAccessToken();
        break;
      case '注册播放器':
        initPlayer();
        break;
      case '开始回放':
        break;
      case '停止回放':
        stopPlayback();
        break;
      case '开始直播':
        startRealPlay();
        break;
      case '停止直播':
        stopRealPlay();
        break;
      case '打开音量':
        openSound();
        break;
      case '关闭音量':
        closeSound();
        break;
      case '截屏':
        capturePicture();
        break;
      case '向左旋转':
        command = 2;
        ptzHandle(0);
        break;
      case '向右旋转':
        command = 3;
        ptzHandle(0);
        break;
      case '向上旋转':
        command = 0;
        ptzHandle(0);
        break;
      case '向下旋转':
        command = 1;
        ptzHandle(0);
        break;
      case '镜头拉近':
        command = 8;
        ptzHandle(0);
        break;
      case '镜头拉远':
        command = 9;
        ptzHandle(0);
        break;
      case '云台停止':
        ptzHandle(1);
        break;
      case '开始录像':
        startRecordFile();
        break;
      case '停止录像':
        stopRecordFile();
        break;
      default:
        break;
    }
  }

  ///初始化萤石sdk
  void initSDK() async {
    await YsPlay.initSdk(appKey);
  }

  ///设置accessToken
  void setAccessToken() async {
    await YsPlay.setAccessToken(accessToken);
  }

  ///注册播放器
  void initPlayer() async {
    bool result = await YsPlay.initEZPlayer(
      deviceSerial,
      verifyCode,
      cameraNo,
    );
  }

  ///停止回放
  void stopPlayback() async {
    await YsPlay.stopPlayback();
  }

  ///开始直播
  void startRealPlay() async {
    await YsPlay.startRealPlay();
  }

  ///停止直播
  void stopRealPlay() async {
    await YsPlay.stopRealPlay();
  }

  ///打开音量
  void openSound() async {
    await YsPlay.openSound();
  }

  ///关闭音量
  void closeSound() async {
    await YsPlay.closeSound();
  }

  ///截屏
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

  /// 云台控制
  void ptzHandle(
    int action, {
    int? speed,
  }) async {
    await YsPlay.ptz(ptzCommand: command, action: action, speed: speed);
  }

  /// 开始录像
  void startRecordFile() async {
    await YsPlay.startRecordWithFile();
  }

  /// 停止录像
  void stopRecordFile() async {
    await YsPlay.stopRecordWithFile();
  }
}
