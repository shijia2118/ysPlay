package com.example.ys_play;

import android.app.Application;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.videogo.exception.BaseException;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;
import com.videogo.openapi.bean.EZDeviceRecordFile;

import java.util.Calendar;
import java.util.List;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;

public class YsPlayPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

    String TAG = "YSPLAY_LOG====>";

    private MethodChannel channel;
    private Application application;
    private EZPlayer ezPlayer = null;
    private FlutterPluginBinding binding;
    private BinaryMessenger messenger;
    BasicMessageChannel<Object> nativeToYsPlay;

    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        application = (Application) binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), Constants.CHANNEL);
        channel.setMethodCallHandler(this);

        this.binding=binding;
        this.messenger=binding.getBinaryMessenger();
        nativeToYsPlay = new BasicMessageChannel<>(messenger, Constants.CHANNEL, new StandardMessageCodec());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "init_sdk":
                ///初始化萤石SDK
                String appKey = call.argument("appKey");
                Log.d(TAG, "appKey = " + appKey);
                boolean initResult = EZOpenSDK.initLib(application, appKey);
                Log.d(TAG, "萤石SDK初始化" + (initResult ? "成功" : "失败"));
                result.success(initResult);
                break;
            case "set_access_token":
                ///设置token
                String AccessToken = call.argument("accessToken");
                EZOpenSDK.getInstance().setAccessToken(AccessToken);
                Log.d(TAG, "token设置成功");
                result.success(true);
                break;
            case "destoryLib":
                ///结束后销毁
                EZOpenSDK.finiLib();
                result.success(true);
                break;
            case "EZPlayer_init":
                ///初始化播放器
                Log.d(TAG, "开始注册播放器");
                binding.getPlatformViewRegistry().registerViewFactory(Constants.CHANNEL, new YsPlayViewFactory(messenger, new OnSurfaceViewCreated() {
                    @Override
                    public void createPlayer(EZPlayer player) {
                        ezPlayer = player;
                        Log.d(TAG, "播放器注册成功");
                    }

                    @Override
                    public void result(boolean isSuccess) {
                        result.success(isSuccess);
                    }


                }));
                break;
            case "startRealPlay":
                //开启直播
                boolean startRealPlay = ezPlayer.startRealPlay();
                Log.d(TAG, "开始直播"+(startRealPlay?"成功":"失败"));
                result.success(startRealPlay);
                break;
            case "stopRealPlay":
                ///停止直播
                boolean stopRealPlay = ezPlayer.stopRealPlay();
                Log.d(TAG, "停止直播"+(stopRealPlay?"成功":"失败"));
                result.success(stopRealPlay);
                break;
            case "release":
                ///释放资源
                ezPlayer.release();
                result.success("success");
                break;
            case "queryPlayback": {
                ///查询远程SD卡存储录像信息列表
                final long callBackFuncId = call.argument("callBackFuncId");
                final long startTime = call.argument("startTime");
                final long endTime = call.argument("endTime");
                final String deviceSerial = call.argument("deviceSerial");
                String verifyCode = call.argument("verifyCode");
                final int cameraNo = call.argument("cameraNo");

                final Calendar startCalendar = Calendar.getInstance();
                startCalendar.setTimeInMillis(startTime);

                final Calendar endCalendar = Calendar.getInstance();
                endCalendar.setTimeInMillis(endTime);

                final Looper looper = Looper.myLooper();
                // Android 4.0 之后不能在主线程中请求HTTP请求
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            List<EZDeviceRecordFile> ezDeviceRecordFiles = EZOpenSDK.getInstance().searchRecordFileFromDevice(deviceSerial, cameraNo, startCalendar, endCalendar);
                            // 发送消息给flutter
                            final String jsonString = new Gson().toJson(ezDeviceRecordFiles);

                            new Handler(looper).post(new Runnable() {
                                @Override
                                public void run() {
                                    YsPlayEntity recordFile = new YsPlayEntity("RecordFile", jsonString);
                                    recordFile.setCallBackFuncId(callBackFuncId);
                                    nativeToYsPlay.send(new Gson().toJson(recordFile));
                                }
                            });

                        } catch (BaseException e) {
                            e.printStackTrace();
                        }
                    }
                }).start();
                result.success("success");
                break;
            }
            case "startPlayback": {
                ///开启回放
                long startTime = call.argument("startTime");
                long endTime = call.argument("endTime");

//            EZOpenSDK.enableP2P(true);
//            EZOpenSDK.showSDKLog(true);

                final Calendar startCalendar = Calendar.getInstance();
                startCalendar.setTimeInMillis(startTime);

                final Calendar endCalendar = Calendar.getInstance();
                endCalendar.setTimeInMillis(endTime);
                boolean startPlayback = ezPlayer.startPlayback(startCalendar, endCalendar);
                Log.d(TAG, "开启回放"+(startPlayback?"成功":"失败"));
                result.success(startPlayback);
                break;
            }
            case "stopPlayback":
                /// 停止回放
                boolean stopPlayback = ezPlayer.stopPlayback();
                Log.d(TAG, "停止回放"+(stopPlayback?"成功":"失败"));
                result.success(stopPlayback);
                break;
            case "sound":
                ///开启和关闭声音
                Boolean bool = call.argument("Sound");
                if (Boolean.TRUE.equals(bool)) {
                    ezPlayer.openSound();
                } else {
                    ezPlayer.closeSound();
                }
                result.success("success");
                break;
            case "getOSDTime": {
                ///getOSDTime获取当前回放时间点，如果回放开始时间8:00，结束时间9:00，getOSDTime时间为8:30，那么播放进度为50%；
                Calendar osdTime = ezPlayer.getOSDTime();
                if (null != osdTime) {
                    long timeInMillis = osdTime.getTimeInMillis();
                    result.success(timeInMillis);
                } else {
                    result.success(0);
                }
                break;
            }
            case "pausePlayback": {
                ///暂停回放
                Calendar osdTime = ezPlayer.getOSDTime();
                ezPlayer.pausePlayback();
                long timeInMillis = osdTime.getTimeInMillis();
                result.success(timeInMillis);
                break;
            }
            case "resumePlayback":
                /// 恢复回放
                ezPlayer.resumePlayback();
                result.success("success");
                break;
            default:
                result.notImplemented();
                break;
        }

    }


    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

}
