import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ys_play/ys_play.dart';
import 'package:ys_play_example/main.dart';
import 'package:ys_play_example/utils/dialog_util.dart';
import 'package:ys_play_example/utils/loading_hepler.dart';
import 'package:ys_play_example/utils/permission_util.dart';
import 'package:app_settings/app_settings.dart';

class PeiwangPage extends StatefulWidget {
  const PeiwangPage({super.key});

  @override
  State<PeiwangPage> createState() => _PeiwangPageState();
}

class _PeiwangPageState extends State<PeiwangPage> with WidgetsBindingObserver {
  TextEditingController deviceSerialController = TextEditingController();
  TextEditingController verifyCodeController = TextEditingController();
  TextEditingController ssidController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  StreamSubscription? subscription;
  List<String> pwMethods = [
    'WIFI配网',
    '热点配网',
    '声波配网',
  ];

  int pwPosition = 0;
  String get pwString => pwMethods[pwPosition];
  String get mode {
    if (pwPosition == 0)
      return 'wifi';
    else if (pwPosition == 1)
      return 'ap';
    else if (pwPosition == 2)
      return 'wave';
    else
      return '';
  }

  bool goSelectWifi = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getLocationPermission();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        deviceSerialField();
      },
    );

    ///配网结果监听
    YsPlay.peiwangResultListener((result) {
      showToast(result.msg ?? '未知结果');
      LoadingHelper.dismiss(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    deviceSerialController.dispose();
    verifyCodeController.dispose();
    ssidController.dispose();
    pwdController.dispose();
    _timer?.cancel();
    YsPlay.stopConfigPw(mode: mode);
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (goSelectWifi) {
          //从后台返回，获取wifi信息
          goSelectWifi = false;
          getWifiInfo();
        }
        break;
      case AppLifecycleState.inactive:
        //app准备进入后台
        break;
      case AppLifecycleState.paused:
        //app进入后台
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 选择配网方式 下拉框
    Widget pwSelectWidget = GestureDetector(
      onTap: selectPwHandle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pwString),
            SizedBox(width: 10),
            Image.asset(
              'assets/arrow_down.png',
              width: 15,
              height: 12,
            ),
          ],
        ),
      ),
    );

    /// 底部提示文字
    Widget reminderText =
        Text('提示:\n若设备指示灯红蓝交替闪烁，请选择WiFi配网。\n若设备指示灯蓝色闪烁，请选择设备热点配网。');

    /// 选择网络按钮
    Widget selectWifiWidget = TextButton(
      onPressed: selectWifiHandle,
      child: Text(
        '选择网络',
        style: TextStyle(color: Colors.blue),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('设备配网'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            field(ssidController, title: 'wifi名称', suffix: selectWifiWidget),
            SizedBox(height: 20),
            field(pwdController, title: 'wifi密码'),
            SizedBox(height: 20),
            Text('若无密码，可不输入。\n注:配网时请使用2g网络.'),
            SizedBox(height: 50),
            CupertinoButton.filled(
              child: Text('下一步'),
              onPressed: startConfigWifi,
            ),
            pwSelectWidget,
            SizedBox(height: 20),
            reminderText,
          ],
        ),
      ),
    );
  }

  /// 获取定位权限
  void getLocationPermission() {
    PermissionUtils.location(
      context,
      action: () => getWifiInfo(),
    );
  }

  ///获取wifi信息
  void getWifiInfo() async {
    NetworkInfo info = NetworkInfo();
    String? wifiName = await info.getWifiName();
    if (wifiName != null) {
      ssidController.text = wifiName.replaceAll("\"", "").trim();
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 输入框简单封装
  Widget field(
    TextEditingController controller, {
    required String title,
    String? placehold,
    Widget? suffix,
  }) {
    suffix ??= Container();
    return Row(
      children: [
        Text(title + ':'),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 40,
            child: CupertinoTextField(
              controller: controller,
              placeholder: placehold,
              suffix: suffix,
            ),
          ),
        ),
      ],
    );
  }

  /// 序列号或验证码输入框
  void deviceSerialField() async {
    await DialogUtil.showCommonDialog(
      context,
      '请输入',
      noCancel: true,
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            field(deviceSerialController, title: '序列号'),
            SizedBox(height: 15),
            field(verifyCodeController, title: '验证码'),
          ],
        ),
      ),
      onTap: () {
        if (deviceSerialController.text.isEmpty) {
          showToast('请输入序列号');
          return;
        }
        Navigator.pop(context);
      },
    );
  }

  /// 选择网络
  void selectWifiHandle() async {
    goSelectWifi = true;
    await AppSettings.openWIFISettings();
  }

  /// 选择配网方式
  void selectPwHandle() {
    Pickers.showSinglePicker(
      context,
      data: pwMethods,
      selectData: pwString,
      onConfirm: ((data, position) {
        pwPosition = position;
        setState(() {});
      }),
    );
  }

  /// 配网
  void startConfigWifi() {
    DialogUtil.showCommonDialog(
      context,
      '提示',
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Text('请长按Reset键重置'),
      ),
      onTap: () async {
        Navigator.pop(context);
        LoadingHelper.showDialogLoading(context, text: '配网中...');
        //配网前先授权登录
        bool result = await YsPlay.setAccessToken(accessToken);
        if (!result) {
          showToast('assessToken有误');
        }

        if (pwPosition == 1) {
          //热点配网
          await YsPlay.startConfigAP(
            deviceSerial: deviceSerialController.text,
            ssid: ssidController.text,
            password: pwdController.text,
            verifyCode: verifyCode,
          );
        } else {
          dismissAfter30s();
          //wifi配网和声波配网
          await YsPlay.startConfigWifi(
            deviceSerial: deviceSerialController.text,
            ssid: ssidController.text,
            password: pwdController.text,
            mode: mode,
          );
        }
      },
    );
  }

  /// 30s后，如果未接收到配网(除ap)回调，则配网失败
  void dismissAfter30s() async {
    if (_timer != null) _timer!.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (t.tick >= 30) {
          if (LoadingHelper.isLoading) {
            LoadingHelper.dismiss(context);
            showToast('配网失败');
            YsPlay.stopConfigPw(mode: mode);
            _timer?.cancel();
          }
        }
      },
    );
  }
}
