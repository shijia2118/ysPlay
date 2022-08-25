
import 'ys_play_platform_interface.dart';

class YsPlay {
  Future<String?> getPlatformVersion() {
    return YsPlayPlatform.instance.getPlatformVersion();
  }

  ///初始化荧石SDK
  Future<bool> initSDK({required String appKey})async{
    return await YsPlayPlatform.instance.init(appKey:appKey)??false;
  }


  ///设置accessToken
  Future<void> setAccessToken({required String accessToken})async{
    YsPlayPlatform.instance.setAccessToken(accessToken: accessToken);
  }
}
