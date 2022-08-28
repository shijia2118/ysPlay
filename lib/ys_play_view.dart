import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ys_play/constants.dart';

class YsPlayView extends StatelessWidget {
  final Map<String,dynamic> creationParams;
  const YsPlayView({Key? key,required this.creationParams,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return  UiKitView(viewType: Constants.METHOD_CHANNEL,creationParams: creationParams,creationParamsCodec: StandardMessageCodec(),);
    } else if (Platform.isAndroid) {
      return  AndroidView(viewType: Constants.METHOD_CHANNEL,creationParams: creationParams,creationParamsCodec: StandardMessageCodec(),);
    } else {
      throw UnimplementedError();
    }
  }
}
