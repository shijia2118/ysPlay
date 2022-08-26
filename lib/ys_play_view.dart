import 'dart:io';

import 'package:flutter/material.dart';

class YsPlayView extends StatelessWidget {
  const YsPlayView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const UiKitView(viewType: 'ys_play');
    } else if (Platform.isAndroid) {
      return const AndroidView(viewType: 'ys_play');
    } else {
      throw UnimplementedError();
    }
  }
}
