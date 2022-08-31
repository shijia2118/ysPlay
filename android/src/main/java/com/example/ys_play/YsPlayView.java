package com.example.ys_play;

import android.app.Application;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.videogo.exception.BaseException;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;
import com.videogo.openapi.bean.EZDeviceRecordFile;

import java.util.Calendar;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;

public class YsPlayView implements PlatformView, MethodChannel.MethodCallHandler {

    @NonNull private final BinaryMessenger messenger;
    private Application application;
    private final SurfaceView surfaceView;
    private EZPlayer ezPlayer = null;
    BasicMessageChannel<Object> nativeToFlutter;
    List<EZDeviceRecordFile> ezDeviceRecordFiles = null;
    Object queryVideoLock = new Object();

    public YsPlayView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams, BinaryMessenger messenger, Application application) {
        this.messenger = messenger;
        this.application = application;
        new MethodChannel(messenger,Constants.CHANNEL).setMethodCallHandler(this);
        nativeToFlutter = new BasicMessageChannel<>(messenger, "nativeToFlutter", new StandardMessageCodec());

        surfaceView = new SurfaceView(context);
    }


    @Override
    public View getView() {
        return surfaceView;
    }

    @Override
    public void dispose() {
        if(null != ezPlayer) {
            ezPlayer.release();
        }
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if(call.method.equals("startRealPlay")) { //开启直播
            boolean value = ezPlayer.startRealPlay();
            result.success(value);
        } else if (call.method.equals("stopRealPlay")) { //停止直播
            boolean value = ezPlayer.stopRealPlay();
            result.success(value);
        } else if (call.method.equals("release")) { //释放资源
            ezPlayer.release();
            result.success(true);
        } else if (call.method.equals("queryPlayback")) { //查询回放视频列表
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
            new Thread(new Runnable(){
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
                                nativeToFlutter.send(new Gson().toJson(recordFile));
                            }
                        });

                    } catch (BaseException e) {
                        e.printStackTrace();
                    }
                }
            }).start();
            result.success(true);
        } else if (call.method.equals("EZPlayer_init")){ //注册播放器
            String deviceSerial = call.argument("deviceSerial");
            String verifyCode = call.argument("verifyCode");
            int cameraNo = call.argument("cameraNo");

            ezPlayer  = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);
            ezPlayer.setHandler(new YsPlayViewHandler(Looper.getMainLooper()));
            ezPlayer.setSurfaceHold(surfaceView.getHolder());
            //设置播放器的显示Surface
            surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
                @Override
                public void surfaceCreated(@NonNull SurfaceHolder holder) {
                    if (ezPlayer != null) {
                        ezPlayer.setSurfaceHold(holder);
                    }
                }

                @Override
                public void surfaceChanged(@NonNull SurfaceHolder holder, int format, int width, int height) {

                }

                @Override
                public void surfaceDestroyed(@NonNull SurfaceHolder holder) {
                    if (ezPlayer != null) {
                        ezPlayer.setSurfaceHold(null);
                    }
                }
            });
            ezPlayer.setSurfaceHold(surfaceView.getHolder());

            ezPlayer.setPlayVerifyCode(verifyCode);
            result.success("success");
        } else if (call.method.equals("startPlayback")) {//开启回放
            long startTime = call.argument("startTime");
            long endTime = call.argument("endTime");
//            EZOpenSDK.enableP2P(true);
//            EZOpenSDK.showSDKLog(true);
            final Calendar startCalendar = Calendar.getInstance();
            startCalendar.setTimeInMillis(startTime);

            final Calendar endCalendar = Calendar.getInstance();
            endCalendar.setTimeInMillis(endTime);
            boolean b = ezPlayer.startPlayback(startCalendar, endCalendar);
            result.success(b);
        } else if (call.method.equals("stopPlayback")) { // 停止回放
            boolean value = ezPlayer.stopPlayback();
            result.success(value);
        } else if (call.method.equals("sound")) { //开启或关闭声音
            Boolean bool = call.argument("Sound");
            boolean value = false;
            if(Boolean.TRUE.equals(bool)) {
                value= ezPlayer.openSound();
            } else {
                value= ezPlayer.closeSound();
            }
            result.success(value);
        } else if (call.method.equals("getOSDTime")) { //获取视频当前时间节点
            Calendar osdTime = ezPlayer.getOSDTime();
            if(null != osdTime){
                long timeInMillis = osdTime.getTimeInMillis();
                result.success(timeInMillis);
            } else {
                result.success(0);
            }
        } else if (call.method.equals("pausePlayback")) { //暂停回放
            Calendar osdTime = ezPlayer.getOSDTime();
            ezPlayer.pausePlayback();
            long timeInMillis = osdTime.getTimeInMillis();
            result.success(timeInMillis);
        } else if (call.method.equals("resumePlayback")) { //恢复回放
            boolean value = ezPlayer.resumePlayback();
            result.success(value);
        } else {
            result.notImplemented();
        }

    }
}
