import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class YsPlayView extends StatelessWidget {
  final Function(int)? onPlatformViewCreated;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const YsPlayView({
    Key? key,
     this.onPlatformViewCreated,
    this.gestureRecognizers,
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
          gestureRecognizers: gestureRecognizers,
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
          gestureRecognizers: gestureRecognizers,
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
