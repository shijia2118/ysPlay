package com.example.hxjt.ys_play;

import android.app.Application;
import android.content.Context;

import androidx.annotation.NonNull;

import com.videogo.openapi.EZOpenSDK;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** YsPlayPlugin */
public class YsPlayPlugin implements FlutterPlugin, MethodCallHandler {

  private static String TAG = "YSPLAY_LOG====";
  private MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "ys_play");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if(call.method.equals("init_sdk")){
      String appKey = call.argument("app_key");
      boolean initResult = initSDK(appKey);
      result.success(initResult);
    } else if(call.method.equals("set_access_token")){
      String accessToken = call.argument("access_token");
      setAccessToken(accessToken);
    }
    else {
      result.notImplemented();
    }
  }

  /**
   * 初始化SDK
   * @param appKey appKey
   * @return boolean
   */
  public boolean initSDK(String appKey){
    if(appKey!=null){
      boolean initResult = EZOpenSDK.initLib((Application) context,appKey);
      String resultText = "失败";
      if(initResult) resultText = "成功";
      Log.i(TAG,"SDK初始化"+resultText);
      return initResult;
    }
    return false;
  }

  /**
   * 设置授权token
   * @param accessToken 一般由服务端提供
   */
  public void setAccessToken(String accessToken){
    if(accessToken!=null&&!accessToken.isEmpty()){
      EZOpenSDK.getInstance().setAccessToken(accessToken);
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
