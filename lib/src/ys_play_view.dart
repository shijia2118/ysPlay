import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class YsPlayView extends StatelessWidget {
  final Function(int) onPlatformViewCreated;
  const YsPlayView({
    Key? key,
    required this.onPlatformViewCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String viewType = 'com.example.ys_play';
    if (Platform.isIOS) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: UiKitView(
          viewType: viewType,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
        ),
      );
    } else if (Platform.isAndroid) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: AndroidView(
          viewType: viewType,
          onPlatformViewCreated: onPlatformViewCreated,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else {
      throw UnimplementedError();
    }
  }
}
