import 'package:flutter/material.dart';
import 'package:ys_play/ys.dart';
import 'package:ys_play_example/main.dart';
import 'package:ys_play_example/play_back_page.dart';
import 'package:ys_play_example/real_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    initYsPlay();
  }

  @override
  void dispose() {
    YsPlay.destroyLib();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('萤石SDK功能测试')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlaybackPage()),
                );
              },
              child: Text(
                '回放',
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RealPage()),
                );
              },
              child: Text(
                '直播',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 初始化萤石SDK
  void initYsPlay() async {
    YsPlay.initSdk(appKey);
  }
}
