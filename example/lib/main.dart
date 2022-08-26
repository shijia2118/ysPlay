import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ys_play/ys_play.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _ysPlayPlugin = YsPlay();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initSDK(appKey: '9ddc4fb7c0ef4996b04dd90156368f7c');
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _ysPlayPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  ///初始化sdk
  Future<void> initSDK({required String appKey}) async {
    await _ysPlayPlugin.initSDK(appKey: appKey);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
