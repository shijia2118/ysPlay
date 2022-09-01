import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class YsPlayView extends StatelessWidget {
  final Map<String, dynamic>? creationParams;
  final Function(int) onPlatformViewCreated;
  const YsPlayView({
    Key? key,
    this.creationParams,
    required this.onPlatformViewCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String viewType = 'com.example.ys_play';
    if(creationParams==null||creationParams!.isEmpty) return Container(color: Colors.black);
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
        child: PlatformViewLink(
          viewType: viewType,
          surfaceFactory: (
              BuildContext context,
              PlatformViewController controller,
              ) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            );
          },
          onCreatePlatformView:(PlatformViewCreationParams params) {
            final AndroidViewController controller =PlatformViewsService.initExpensiveAndroidView(
              id: params.id,
              viewType: 'plugins.flutter.io/mapbox_gl',
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            );
            controller.addOnPlatformViewCreatedListener(
              params.onPlatformViewCreated,
            );
            controller.addOnPlatformViewCreatedListener(
              onPlatformViewCreated,
            );
            return controller;
          },
        ),
        // AndroidView(
        //   viewType: viewType,
        //   creationParams: creationParams,
        //   creationParamsCodec: const StandardMessageCodec(),
        //   onPlatformViewCreated: onPlatformViewCreated,
        // ),
      );
    } else {
      throw UnimplementedError();
    }
  }
}
