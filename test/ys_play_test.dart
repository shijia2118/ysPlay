import 'package:flutter_test/flutter_test.dart';
import 'package:ys_play/ys_play.dart';
import 'package:ys_play/ys_play_platform_interface.dart';
import 'package:ys_play/ys_play_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockYsPlayPlatform with MockPlatformInterfaceMixin implements YsPlayPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool?> init({required String appKey}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setAccessToken({required String accessToken}) {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() {
    throw UnimplementedError();
  }

  @override
  Future<void> createPlayer(
      {required String deviceCode, required int cameraNo, required String verifyCode}) {
    throw UnimplementedError();
  }
}

void main() {
  final YsPlayPlatform initialPlatform = YsPlayPlatform.instance;

  test('$MethodChannelYsPlay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelYsPlay>());
  });

  test('getPlatformVersion', () async {
    YsPlay ysPlayPlugin = YsPlay();
    MockYsPlayPlatform fakePlatform = MockYsPlayPlatform();
    YsPlayPlatform.instance = fakePlatform;

    expect(await ysPlayPlugin.getPlatformVersion(), '42');
  });
}
