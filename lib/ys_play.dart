import 'ys_play_platform_interface.dart';

class YsPlay {
  Future<String?> getPlatformVersion() {
    return YsPlayPlatform.instance.getPlatformVersion();
  }

  ///初始化荧石SDK
  Future<bool> initSDK({required String appKey}) async {
    return await YsPlayPlatform.instance.init(appKey: appKey) ?? false;
  }

  ///设置accessToken
  Future<void> setAccessToken({required String accessToken}) async {
    YsPlayPlatform.instance.setAccessToken(accessToken: accessToken);
  }

  ///初始化播放器
  Future<void> createPlayer({required String deviceCode,required String cameraNo,required String verifyCode}) async {
    YsPlayPlatform.instance.createPlayer(deviceCode: deviceCode, cameraNo: cameraNo, verifyCode: verifyCode);
  }

  ///销毁
  Future<void> dispose() async {
    await YsPlayPlatform.instance.dispose();
  }

}
