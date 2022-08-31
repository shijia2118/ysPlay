package com.example.ys_play;

import android.app.Application;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.example.ys_play.Entity.InitPlayerEntity;
import com.example.ys_play.Entity.YsPlayEntity;
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

    String TAG = "萤石LOG=======>";

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
        nativeToYsPlay = new BasicMessageChannel<>(messenger, Constants.RECORD_FILE_CHANNEL, new StandardMessageCodec());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            ///初始化萤石SDK
            case "init_sdk":{
                String appKey = call.argument("appKey");
                Log.d(TAG, "appKey = " + appKey);
                boolean value = EZOpenSDK.initLib(application, appKey);
                Log.d(TAG, "SDK初始化:" + value);
                result.success(value);
                break;
            }

            ///绑定账号
            case "set_access_token":
                String AccessToken = call.argument("accessToken");
                EZOpenSDK.getInstance().setAccessToken(AccessToken);
                Log.d(TAG, "token设置成功");
                result.success(true);
                break;

            ///结束后销毁
            case "destoryLib":
                EZOpenSDK.finiLib();
                result.success(true);
                break;

            ///初始化播放器
            case "EZPlayer_init":
                binding.getPlatformViewRegistry().registerViewFactory(Constants.CHANNEL,new YsPlayViewFactory(messenger, new InitPlayerCallback() {
                    @Override
                    public void data(InitPlayerEntity playerEntity) {
                        if(playerEntity.getPlayer()!=null){
                            ezPlayer = playerEntity.getPlayer();
                        }
                        Log.d(TAG, "注册播放器成功");
                        result.success(true);
                    }
                }));
                break;

            ///开启直播
            case "startRealPlay":{
                boolean value = ezPlayer.startRealPlay();
                Log.d(TAG, "开启直播:"+(value?"成功":"失败"));
                result.success(value);
                break;
            }

            ///停止直播
            case "stopRealPlay":{
                boolean value = ezPlayer.stopRealPlay();
                Log.d(TAG, "停止直播"+value);
                result.success(value);
                break;
            }

            ///释放资源
            case "release":
                ezPlayer.release();
                result.success(true);
                break;

            ///查询远程SD卡存储录像信息列表
            case "queryPlayback": {
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
                result.success(true);
                break;
            }

            ///开启回放
            case "startPlayback": {
                long startTime = call.argument("startTime");
                long endTime = call.argument("endTime");

//            EZOpenSDK.enableP2P(true);
//            EZOpenSDK.showSDKLog(true);

                final Calendar startCalendar = Calendar.getInstance();
                startCalendar.setTimeInMillis(startTime);

                final Calendar endCalendar = Calendar.getInstance();
                endCalendar.setTimeInMillis(endTime);
                boolean value = ezPlayer.startPlayback(startCalendar, endCalendar);
                Log.d(TAG, "开启回放:"+value);
                result.success(value);
                break;
            }

            /// 停止回放
            case "stopPlayback":{
                boolean value = ezPlayer.stopPlayback();
                Log.d(TAG, "停止回放:"+value);
                result.success(value);
                break;
            }

            ///开启和关闭声音
            case "sound":
                Boolean bool = call.argument("Sound");
                if (Boolean.TRUE.equals(bool)) {
                    ezPlayer.openSound();
                } else {
                    ezPlayer.closeSound();
                }
                result.success(true);
                break;

            ///getOSDTime获取当前回放时间点，如果回放开始时间8:00，结束时间9:00，getOSDTime时间为8:30，那么播放进度为50%；
            case "getOSDTime": {
                Calendar osdTime = ezPlayer.getOSDTime();
                if (null != osdTime) {
                    long timeInMillis = osdTime.getTimeInMillis();
                    result.success(timeInMillis);
                } else {
                    result.success(0);
                }
                break;
            }

            ///暂停回放
            case "pausePlayback": {
                Calendar osdTime = ezPlayer.getOSDTime();
                ezPlayer.pausePlayback();
                long timeInMillis = osdTime.getTimeInMillis();
                result.success(timeInMillis);
                break;
            }

            /// 恢复回放
            case "resumePlayback":
                ezPlayer.resumePlayback();
                result.success(true);
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
