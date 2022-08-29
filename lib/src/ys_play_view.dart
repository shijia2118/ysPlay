import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YsPlayView extends StatelessWidget {
  final Map<String, dynamic> creationParams;
  final Function(int)? onPlatformViewCreated;
  const YsPlayView({
    Key? key,
    required this.creationParams,
    this.onPlatformViewCreated,
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
          creationParams: creationParams,
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
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
        ),
      );
    } else {
      throw UnimplementedError();
    }
  }
}
