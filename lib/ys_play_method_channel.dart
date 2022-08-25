import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ys_play_platform_interface.dart';

/// An implementation of [YsPlayPlatform] that uses method channels.
class MethodChannelYsPlay extends YsPlayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ys_play');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> init({required String appKey}) async {
    bool? result = await methodChannel.invokeMethod('init_sdk', {'app_key': appKey});
    return result ?? false;
  }

  @override
  Future<void> setAccessToken({required String accessToken}) async {
    await methodChannel.invokeMethod('set_access_token', {'access_token': accessToken});
  }

  @override
  Future<void> dispose() async {
    await methodChannel.invokeMethod('dispose');
  }
}
