import 'package:flutter/material.dart';
import 'package:ys_play_example/ys_player.dart';

import 'main.dart';

class RealPage extends StatefulWidget {
  const RealPage({Key? key}) : super(key: key);

  @override
  State<RealPage> createState() => _RealPageState();
}

class _RealPageState extends State<RealPage> {
  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
