package com.example.ys_play;

import android.app.Application;
import android.content.Intent;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.example.ys_play.Entity.YsPlayerStatusEntity;
import com.example.ys_play.Interface.PlayerStatusListener;
import com.example.ys_play.utils.TimeUtils;
import com.google.gson.Gson;
import com.videogo.exception.BaseException;
import com.videogo.openapi.EZConstants;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;

import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import io.flutter.BuildConfig;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMessageCodec;

public class YsPlayPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

    final String TAG = "萤石LOG=========>";
    private Application application;
    private EZPlayer ezPlayer;
    private SurfaceView surfaceView;
    BasicMessageChannel<Object> playerStatusResult;

    private String deviceSerial;
    private Integer cameraNo;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        application = (Application) binding.getApplicationContext();
        BinaryMessenger messenger = binding.getBinaryMessenger();

        /// 注册播放视图
        binding.getPlatformViewRegistry().registerViewFactory(
                Constants.CHANNEL,
                new YsPlayViewFactory((surfaceView) -> {
                    this.surfaceView = surfaceView;
                    //设置播放器的显示Surface
                    surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
                        @Override
                        public void surfaceCreated(@NonNull SurfaceHolder holder) {
                            Log.d(TAG,"surfaceCreated");
                            if (ezPlayer != null) {
                                ezPlayer.setSurfaceHold(holder);
                            }
                        }

                        @Override
                        public void surfaceChanged(@NonNull SurfaceHolder holder, int format, int width, int height) {
                            Log.d(TAG,"surfaceChanged");

                        }

                        @Override
                        public void surfaceDestroyed(@NonNull SurfaceHolder holder) {
                            Log.d(TAG,"surfaceDestroyed");
                            if (ezPlayer != null) {
                                ezPlayer.setSurfaceHold(null);
                            }
                        }
                    });
                })
        );

        ///建立flutter和android端的通信通道
        new MethodChannel(messenger, Constants.CHANNEL).setMethodCallHandler(this);

        /// 播放器状态改变时，传递消息到flutter端
        playerStatusResult =  new BasicMessageChannel<>(messenger, Constants.PLAYER_STATUS_CHANNEL, new StandardMessageCodec());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "init_sdk":
                EZOpenSDK.showSDKLog(BuildConfig.DEBUG);
                String appKey = call.argument("appKey");
                boolean initResult = EZOpenSDK.initLib(this.application, appKey);
                Log.d(TAG,"初始化"+(initResult?"成功":"失败"));
                result.success(initResult);
                break;
            case "set_access_token":
                String accessToken = call.argument("accessToken");
                EZOpenSDK.getInstance().setAccessToken(accessToken);
                Log.d(TAG,"token设置成功");
                result.success(true);
                break;
            case "destroyLib":
                /// 销毁萤石SDK
                EZOpenSDK.finiLib();
                break;
            case "EZPlayer_init":
                //初始化播放器
                deviceSerial = call.argument("deviceSerial");
                String verifyCode = call.argument("verifyCode");
                cameraNo = call.argument("cameraNo");
                if(cameraNo==null) cameraNo=1;

                ezPlayer  = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);

                ezPlayer.setHandler(new YsPlayViewHandler(playerStatusListener));
                ezPlayer.setSurfaceHold(surfaceView.getHolder());
                ezPlayer.setPlayVerifyCode(verifyCode);
                Log.d(TAG,"播放器初始化成功");
                result.success(true);
                break;
            case "startPlayback":
                ///开启回放
                if(ezPlayer==null) return;
                if(call.hasArgument("startTime")&&call.hasArgument("endTime")){
                    Long startTime = call.argument("startTime");
                    Long endTime = call.argument("endTime");
                    if(startTime==null||endTime==null){
                        Log.d(TAG,"startTime或endTime均不能为空");
                        result.success(false);
                    }else{
                        final Calendar startCalendar = Calendar.getInstance();
                        startCalendar.setTimeInMillis(startTime);
                        final Calendar endCalendar = Calendar.getInstance();
                        endCalendar.setTimeInMillis(endTime);
                        boolean isSuccess = ezPlayer.startPlayback(startCalendar, endCalendar);
                        Log.d(TAG,"开启回放"+(isSuccess?"成功":"失败"));
                        result.success(isSuccess);
                    }
                }else {
                    Log.d(TAG,"startTime或endTime均不能为空");
                    result.success(false);
                }
                break;
            case "pause_play_back":
                /// 暂停回放
                if(ezPlayer==null) return;
                boolean isPause = ezPlayer.pausePlayback();
                Log.d(TAG,"暂停回放"+(isPause?"成功":"失败"));
                result.success(isPause);
                break;
            case "resume_play_back":
                /// 恢复回放
                if(ezPlayer==null) return;
                boolean isResume = ezPlayer.resumePlayback();
                Log.d(TAG,"恢复回放"+(isResume?"成功":"失败"));
                result.success(isResume);
                break;
            case "stopPlayback":
                 /// 停止回放
                if(ezPlayer==null) return;
                boolean isSuccess = ezPlayer.stopPlayback();
                 Log.d(TAG,"停止回放"+(isSuccess?"成功":"失败"));
                 result.success(isSuccess);
                 break;
            case "startRealPlay":
                ///开启直播
                if(ezPlayer==null) return;
                if(ezPlayer!=null){
                    boolean realStartResult = ezPlayer.startRealPlay();
                    Log.d(TAG,"开始直播"+(realStartResult?"成功":"失败"));
                    result.success(realStartResult);
                }else{
                    Log.d(TAG,"ezPlayer不能为空");
                    result.success(false);
                }
                break;
            case "stopRealPlay":
                ///停止直播
                if(ezPlayer==null) return;
                boolean stopRealResult = ezPlayer.stopRealPlay();
                Log.d(TAG,"停止直播"+(stopRealResult?"成功":"失败"));
                result.success(stopRealResult);
                break;
            case "openSound":
                /// 打开声音
                if(ezPlayer==null) return;
                boolean openResult = ezPlayer.openSound();
                Log.d(TAG,"打开声音"+(openResult?"成功":"失败"));
                result.success(openResult);
                break;
            case "closeSound":
                /// 关闭声音
                if(ezPlayer==null) return;
                boolean closeResult = ezPlayer.closeSound();
                Log.d(TAG,"关闭声音"+(closeResult?"成功":"失败"));
                result.success(closeResult);
                break;
            case "capturePicture":
                /// 截屏
                if(ezPlayer==null) return;
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        String fileName = Environment.getExternalStorageDirectory().getPath() + "/DCIM/" + TimeUtils.dateToString(TimeUtils.getTimeStame(), "yyyyMMddHHmmss") + ".png";
                        int captureResult = ezPlayer.capturePicture(fileName);
                        if(captureResult==0){
                            application.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + fileName)));
                        }
                        result.success(captureResult==0);
                    }
                }).start();
                break;

            case "release":
                /// 释放资源
                if(ezPlayer!=null){
                    ezPlayer.setSurfaceHold(null);
                    surfaceView=null;
                    ezPlayer.release();
                }
                break;
            case "ptz":
                /// 云台控制
                if(call.hasArgument("command") && call.hasArgument("action")){
                    Integer command = call.argument("command");
                    Integer action = call.argument("action");
                    Integer speed = call.argument("speed");

                    if(command==null) command = 0;
                    if(action==null) action = 0;
                    if(speed==null) speed = 1;

                    EZConstants.EZPTZCommand ezptzCommand = EZConstants.EZPTZCommand.EZPTZCommandUp;
                    switch (command) {
                        case 1:
                            ezptzCommand = EZConstants.EZPTZCommand.EZPTZCommandDown;
                            break;
                        case 2:ezptzCommand = EZConstants.EZPTZCommand.EZPTZCommandLeft;break;
                        case 3 :ezptzCommand = EZConstants.EZPTZCommand.EZPTZCommandRight;break;
                        case 8 :ezptzCommand = EZConstants.EZPTZCommand.EZPTZCommandZoomIn;break;
                        case 9 :ezptzCommand = EZConstants.EZPTZCommand.EZPTZCommandZoomOut;break;
                        default :break;
                    }

                    EZConstants.EZPTZAction ezptzAction = EZConstants.EZPTZAction.EZPTZActionSTART;
                    if(action==1){
                        ezptzAction = EZConstants.EZPTZAction.EZPTZActionSTOP;
                    }
                    EZConstants.EZPTZCommand finalEzptzCommand = ezptzCommand;
                    EZConstants.EZPTZAction finalEzptzAction = ezptzAction;
                    Integer finalSpeed = speed;
                    // 记得在子线程中调用
                    new Thread(){
                        public void run(){
                            Looper.prepare();
                            new Handler().post(new Runnable() {
                                @Override
                                public void run() {
                                    try {
                                        boolean  ptzResult =  EZOpenSDK.getInstance().controlPTZ(deviceSerial,cameraNo, finalEzptzCommand, finalEzptzAction, finalSpeed);
                                        result.success(ptzResult);
                                    } catch ( BaseException e) {
                                        Log.i(TAG,""+e);
                                        Toast.makeText(application, e.toString(), Toast.LENGTH_SHORT).show();
                                        result.success(false);
                                    }
                                }
                            });
                            Looper.loop();
                        }
                    }.start();
                }
                break;
            case "start_record":
                /// 开始录像前，先结束本地直播流录像
                if(ezPlayer==null) return;
                ezPlayer.stopLocalRecord();
                String recordFile = Environment.getExternalStorageDirectory().getPath() + "/DCIM/" + TimeUtils.dateToString(TimeUtils.getTimeStame(), "yyyyMMddHHmmss") + ".mp4";

                boolean recordResult = ezPlayer.startLocalRecordWithFile(recordFile);
                Log.d(TAG,"开启录像"+(recordResult?"成功":"失败"));
                if(recordResult){
                    application.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + recordFile)));
                }
                result.success(recordResult);
                break;
            case "stop_record":
                /// 停止录像
                if(ezPlayer==null) return;
                boolean stopRecordResult = ezPlayer.stopLocalRecord();
                Log.d(TAG,"停止录像"+(stopRecordResult?"成功":"失败"));
                result.success(stopRecordResult);
                break;
            case "set_video_level":
                /// 设置视频清晰度
                /// videoLevel – 清晰度 0-流畅 1-均衡 2-高品质
                if(call.hasArgument("deviceSerial")
                        &&call.hasArgument("cameraNo")
                        &&call.hasArgument("videoLevel")){
                   String deviceSerial = call.argument("deviceSerial");
                   Integer cameraNo = call.argument("cameraNo");
                   if(cameraNo==null) cameraNo=1;
                   Integer videoLevel = call.argument("videoLevel");
                   if(videoLevel==null) videoLevel=2;

                   if(deviceSerial != null){
                       Integer finalCameraNo = cameraNo;
                       Integer finalVideoLevel = videoLevel;
                       new Thread(){
                           public void run(){
                               Looper.prepare();
                               new Handler().post(new Runnable() {
                                   @Override
                                   public void run() {
                                       try {
                                           boolean vlResult =  EZOpenSDK.getInstance().setVideoLevel(deviceSerial, finalCameraNo, finalVideoLevel);
                                           result.success(vlResult);
                                       } catch ( BaseException e) {
                                           Log.i(TAG,""+e);
                                           Toast.makeText(application, e.toString(), Toast.LENGTH_SHORT).show();
                                           result.success(false);
                                       }
                                   }
                               });
                               Looper.loop();
                           }
                       }.start();
                    }
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * 播放器状态监听回调
     */
    PlayerStatusListener playerStatusListener = new PlayerStatusListener() {
        @Override
        public void onSuccess() {
            Log.d(TAG,"播放成功");
            YsPlayerStatusEntity entity = new YsPlayerStatusEntity();
            entity.setIsSuccess(true);
            playerStatusResult.send(new Gson().toJson(entity));
        }

        @Override
        public void onError(String errorInfo) {
            Log.d(TAG,"播放失败:"+errorInfo);
            YsPlayerStatusEntity entity = new YsPlayerStatusEntity();
            entity.setIsSuccess(false);
            entity.setErrorInfo(errorInfo);
            playerStatusResult.send(new Gson().toJson(entity));
        }
    };


}
