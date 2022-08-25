import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ys_play_method_channel.dart';

abstract class YsPlayPlatform extends PlatformInterface {
  /// Constructs a YsPlayPlatform.
  YsPlayPlatform() : super(token: _token);

  static final Object _token = Object();

  static YsPlayPlatform _instance = MethodChannelYsPlay();

  /// The default instance of [YsPlayPlatform] to use.
  ///
  /// Defaults to [MethodChannelYsPlay].
  static YsPlayPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [YsPlayPlatform] when
  /// they register themselves.
  static set instance(YsPlayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  ///初始化SDK
  Future<bool?> init({required String appKey}) {
    throw UnimplementedError('init() has not been implemented.');
  }

  ///设置accessToken
  Future<void> setAccessToken({required String accessToken}) {
    throw UnimplementedError('setAccessToken() has not been implemented.');
  }
}
