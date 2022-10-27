// 萤石云参数
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ys_play/ys.dart';

String appKey = '9ddc4fb7c0ef4996b04dd90156368f7c';
String accessToken = 'ra.anwc4gsd1u2s5zfm1kbi677pb9rf2yue-4ua2byabn1-1a9no9q-qm91aih37';
String deviceSerial = 'C63167422';
String verifyCode = 'PDSWCZ';
int cameraNo = 1;

class MyButton1 extends StatelessWidget {
  const MyButton1(
      {required this.contentWidget, required this.onTapAction, required this.direction, Key? key})
      : super(key: key);

  final Widget contentWidget;
  final Function onTapAction;
  final int direction;

  @override
  Widget build(BuildContext context) {
    // GestureDetector手势识别 up 事件有时候会不触发
    // 如果手指不是在 GestureDetector widget 上抬起，那么不会触发up事件
    return Listener(
      onPointerDown: (tapDown) {
        // print('MyButton was onTapDown!');
        // var requestData = YS7PtzRequestEntity(
        //   accessToken: accessToken,
        //   deviceSerial: deviceSerial,
        //   channelNo: cameraNo,
        //   direction: direction,
        //   speed: 1,
        // );
        // YsPlay.ptzStart(requestData).then((res){
        //   print("onTapDown $res");
        // });
      },
      onPointerUp: (tapUp) {
        // if (onTapAction != null) {
        //   onTapAction('myButton was hello world');
        // }
        // print('MyButton was onTapUp!');
        // var requestData = YS7PtzRequestEntity(
        //   accessToken: accessToken,
        //   deviceSerial: deviceSerial,
        //   channelNo: cameraNo,
        //   direction: direction,
        //   speed: 1,
        // );
        // FlutterYs7.ptzStop(requestData).then((res){
        //   print("onTapUp $res");
        // });
      },
      child: contentWidget,
    );
  }
}

class MyButton2 extends StatelessWidget {
  const MyButton2({this.contentWidget, this.onTapAction, Key? key, this.onTapDown, this.onTapUp})
      : super(key: key);

  final Widget? contentWidget;
  final Function? onTapAction;
  final Function? onTapDown;
  final Function? onTapUp;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onTapAction != null) {
          onTapAction!('myButton was hello world');
        }
      },
      onTapDown: (tapDown) {
        if (onTapDown != null) {
          onTapDown!(tapDown);
        }
      },
      onTapUp: (tapUp) {
        if (onTapUp != null) {
          onTapUp!(tapUp);
        }
      },
      child: contentWidget,
    );
  }
}

class MyView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyViewState();
  }

  void rowTap(int index) {}

  const MyView({Key? key}) : super(key: key);
}

class _MyViewState extends State<MyView> {
  //
  String backTime = 'xx';
  int backTimeTmp = 0;
  Timer? startPlayTime;
  Timer? timeId;
  bool isSurfaceCreated = false;
  Map<String, dynamic> creationParams = {
    'deviceSerial': deviceSerial,
    'verifyCode': verifyCode,
    'cameraNo': 1,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: isSurfaceCreated
                ? YsPlayView(
                    creationParams: creationParams,
                    onPlatformViewCreated: (i) {},
                  )
                : Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MyButton2(
                onTapAction: (str) {
                  YsPlay.initSdk(appKey);
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('INIT SDK'),
                  ),
                ),
              ),
              MyButton2(
                onTapAction: (str) {
                  YsPlay.setAccessToken(accessToken);
                  YsPlay.initEZPlayer(deviceSerial, verifyCode, cameraNo,
                      playerStatus: (status) {});
                  setState(() {
                    isSurfaceCreated = true;
                  });
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('初始化播放器'),
                  ),
                ),
              ),
              MyButton2(
                onTapAction: (str) {
                  YsPlay.startRealPlay();
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('开始直播'),
                  ),
                ),
              ),
              MyButton2(
                onTapAction: (str) {
                  YsPlay.stopRealPlay();
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('停止直播'),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              MyButton1(
                direction: 0,
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('云台向上'),
                  ),
                ),
                onTapAction: () {},
              ),
              MyButton1(
                direction: 1,
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('云台向下'),
                  ),
                ),
                onTapAction: () {},
              ),
              MyButton1(
                direction: 2,
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('云台向左'),
                  ),
                ),
                onTapAction: () {},
              ),
              MyButton1(
                direction: 3,
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('云台向右'),
                  ),
                ),
                onTapAction: () {},
              ),
            ],
          ),
          Row(
            children: [
              MyButton1(
                direction: 8,
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('放大'),
                  ),
                ),
                onTapAction: () {},
              ),
              MyButton1(
                direction: 9,
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('缩小'),
                  ),
                ),
                onTapAction: () {},
              ),
              MyButton1(
                direction: 10,
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('近焦距'),
                  ),
                ),
                onTapAction: () {},
              ),
              MyButton1(
                direction: 11,
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('远焦距'),
                  ),
                ),
                onTapAction: () {},
              ),
            ],
          ),
          Row(
            children: [
              MyButton2(
                onTapAction: (str) async {
                  var request = YsViewRequestEntity();
                  request.cameraNo = 1;
                  request.deviceSerial = deviceSerial;
                  request.verifyCode = verifyCode;
                  request.startTime = 1630368000000;
                  request.endTime = 1630425600000;

                  YsPlay.queryPlayback(request, (data) {});
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('查询回放'),
                  ),
                ),
              ),
              MyButton2(
                onTapAction: (str) async {
                  DatePicker.showDateTimePicker(
                    context,
                    // 是否展示顶部操作按钮
                    showTitleActions: true,
                    onChanged: (date) {
                      // change事件
                    },
                    onConfirm: (DateTime date) async {
                      // 确定事件
                      setState(() {
                        backTime = date.toString().substring(0, 19);
                      });
                    },
                    // 当前时间
                    currentTime: DateTime.now(),
                  );
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('选择回放日期时间'),
                  ),
                ),
              ),
              Text(backTime)
            ],
          ),
          Row(
            children: [
              MyButton2(
                onTapAction: (str) async {
                  DateTime date = DateTime.parse(backTime);
                  var startTime = date.millisecondsSinceEpoch;
                  var endTime = date.millisecondsSinceEpoch + (1000 * 60 * 30);

                  var videoRequest = YsViewRequestEntity();
                  // videoRequest.startTime = 1630422000000;
                  // videoRequest.endTime = 1630422010000;
                  videoRequest.startTime = startTime;
                  videoRequest.endTime = endTime;
                  YsPlay.startPlayback(videoRequest);
                  getplayBackTime();
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('开始回放'),
                  ),
                ),
              ),
              MyButton2(
                onTapAction: (str) async {
                  await YsPlay.stopPlayback();
                  if (startPlayTime != null) {
                    startPlayTime!.cancel();
                  }
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('停止回放'),
                  ),
                ),
              ),
              MyButton2(
                onTapDown: (tapDown) async {
                  startPlayTime?.cancel();
                  backTimeTmp = DateTime.parse(backTime).millisecondsSinceEpoch;

                  if (timeId != null) timeId!.cancel();
                  timeId = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                    backTimeTmp -= 15000;
                    setState(() {
                      backTime = DateTime.fromMillisecondsSinceEpoch(backTimeTmp)
                          .toString()
                          .substring(0, 19);
                    });
                  });
                },
                onTapUp: (tapUp) async {
                  if (timeId != null) {
                    timeId!.cancel();
                  }

                  await YsPlay.stopPlayback();

                  var request = YsViewRequestEntity();
                  request.startTime = backTimeTmp;
                  request.endTime = request.startTime! + (1000 * 60 * 30);
                  YsPlay.startPlayback(request);
                  getplayBackTime();
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('快退'),
                  ),
                ),
              ),
              MyButton2(
                onTapDown: (tapDown) {
                  startPlayTime?.cancel();
                  backTimeTmp = DateTime.parse(backTime).millisecondsSinceEpoch;

                  if (timeId != null) timeId?.cancel();
                  timeId = Timer.periodic(const Duration(milliseconds: 100), (timer) {
                    backTimeTmp += 15000;
                    setState(() {
                      backTime = DateTime.fromMillisecondsSinceEpoch(backTimeTmp)
                          .toString()
                          .substring(0, 19);
                    });
                  });
                },
                onTapUp: (tapUp) async {
                  if (timeId != null) {
                    timeId!.cancel();
                  }

                  await YsPlay.stopPlayback();

                  var request = YsViewRequestEntity();
                  request.startTime = backTimeTmp;
                  request.endTime = request.startTime! + (1000 * 60 * 30);
                  YsPlay.startPlayback(request);
                  getplayBackTime();
                },
                contentWidget: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text('快进'),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void getplayBackTime() {
    if (Platform.isIOS) {
      return;
    }
    if (startPlayTime != null) {
      startPlayTime!.cancel();
    }
    startPlayTime = Timer.periodic(const Duration(seconds: 1), (timer) async {
      int playTime = await YsPlay.getOSDTime();
      var date = DateTime.fromMillisecondsSinceEpoch(playTime);
      setState(() {
        backTime = date.toString().substring(0, 19);
      });
    });
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(body: MyView()),
    ),
  );
}
