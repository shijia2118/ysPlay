// import 'package:flutter_test/flutter_test.dart';
// import 'package:ys_play/ys.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockYsPlayPlatform with MockPlatformInterfaceMixin implements YsPlayPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final YsPlayPlatform initialPlatform = YsPlayPlatform.instance;

//   test('$MethodChannelYsPlay is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelYsPlay>());
//   });

//   test('getPlatformVersion', () async {
//     YsPlay ysPlayPlugin = YsPlay();
//     MockYsPlayPlatform fakePlatform = MockYsPlayPlatform();
//     YsPlayPlatform.instance = fakePlatform;

//     expect(await ysPlayPlugin.getPlatformVersion(), '42');
//   });
// }
