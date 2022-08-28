import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ys_play/constants.dart';

class YsPlayView extends StatelessWidget {
  const YsPlayView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return  UiKitView(viewType: Constants.METHOD_CHANNEL);
    } else if (Platform.isAndroid) {
      return  AndroidView(viewType: Constants.METHOD_CHANNEL);
    } else {
      throw UnimplementedError();
    }
  }
}
