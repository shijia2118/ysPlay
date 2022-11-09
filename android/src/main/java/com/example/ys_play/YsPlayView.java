package com.example.ys_play;

import android.content.Context;
import android.view.SurfaceView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.ys_play.Interface.OnPlatformViewCreated;
import com.videogo.openapi.EZPlayer;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;

public class YsPlayView implements PlatformView{

    private EZPlayer ezPlayer = null;
    private final SurfaceView surfaceView;
    static String TAG = "===========>";

    public YsPlayView(@NonNull Context context, BinaryMessenger messenger, OnPlatformViewCreated onViewCreated){
        surfaceView = new SurfaceView(context);
        onViewCreated.callback(surfaceView);
    }

//    @Override
//    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
//        if (call.method.equals("EZPlayer_init")){
//            //初始化播放器
//            String deviceSerial = call.argument("deviceSerial");
//            String verifyCode = call.argument("verifyCode");
//            Integer cameraNo = call.argument("cameraNo");
//            if(cameraNo==null) cameraNo = -1;
//
//            ezPlayer  = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);
//            ezPlayer.setHandler(new YsPlayViewHandler());
//            ezPlayer.setSurfaceHold(surfaceView.getHolder());
//            //设置播放器的显示Surface
//            surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
//                @Override
//                public void surfaceCreated(@NonNull SurfaceHolder holder) {
//                    if (ezPlayer != null) {
//                        ezPlayer.setSurfaceHold(holder);
//                    }
//                }
//
//                @Override
//                public void surfaceChanged(@NonNull SurfaceHolder holder, int format, int width, int height) {
//
//                }
//
//                @Override
//                public void surfaceDestroyed(@NonNull SurfaceHolder holder) {
//                    if (ezPlayer != null) {
//                        ezPlayer.setSurfaceHold(null);
//                    }
//                }
//            });
//            ezPlayer.setSurfaceHold(surfaceView.getHolder());
//            ezPlayer.setPlayVerifyCode(verifyCode);
//            result.success(true);
//        } else if (call.method.equals("release")) {
//            ///停止后，释放资源
//            ezPlayer.release();
//            result.success(true);
//        } else if (call.method.equals("startPlayback")) {
//            ///开启回放
//            if(call.hasArgument("startTime")&&call.hasArgument("endTime")){
//                Long startTime = call.argument("startTime");
//                Long endTime = call.argument("endTime");
//                if(startTime==null||endTime==null){
//                    Log.d(TAG,"startTime或endTime均不能为空");
//                    result.success(false);
//                }else{
//                    final Calendar startCalendar = Calendar.getInstance();
//                    startCalendar.setTimeInMillis(startTime);
//                    final Calendar endCalendar = Calendar.getInstance();
//                    endCalendar.setTimeInMillis(endTime);
//                    boolean isSuccess = ezPlayer.startPlayback(startCalendar, endCalendar);
//                    Log.d(TAG,"开启回放"+(isSuccess?"成功":"失败"));
//                    result.success(isSuccess);
//                }
//            }
//        } else if (call.method.equals("stopPlayback")) {
//            /// 停止回放
//            boolean isSuccess = ezPlayer.stopPlayback();
//            Log.d(TAG,"停止回放"+(isSuccess?"成功":"失败"));
//            result.success(isSuccess);
//        } else if (call.method.equals("sound")) {
//            //打开或关闭声音
//            Boolean isOpen = call.argument("open");
//            if(isOpen==null) isOpen = true;
//            boolean isSuccess = false;
//            if(isOpen) {
//                isSuccess=  ezPlayer.openSound();
//            } else {
//                isSuccess=  ezPlayer.closeSound();
//            }
//            result.success(isSuccess);
//        } else if (call.method.equals("getOSDTime")) {
//            /// 获取当前回放时间点
//            Calendar osdTime = ezPlayer.getOSDTime();
//            if(null != osdTime){
//                long timeInMillis = osdTime.getTimeInMillis();
//                result.success(timeInMillis);
//            } else {
//                result.success(0);
//            }
//        } else if (call.method.equals("pausePlayback")) {
//            /// 暂停回放
//            Calendar osdTime = ezPlayer.getOSDTime();
//            ezPlayer.pausePlayback();
//            long timeInMillis = osdTime.getTimeInMillis();
//            result.success(timeInMillis);
//        } else if (call.method.equals("resumePlayback")) {
//            /// 恢复回放
//            boolean isSuccess = ezPlayer.resumePlayback();
//            result.success(isSuccess);
//        } else {
//            result.notImplemented();
//        }
////        else if (call.method.equals("queryPlayback")) {
////            final long callBackFuncId = call.argument("callBackFuncId");
////            final long startTime = call.argument("startTime");
////            final long endTime = call.argument("endTime");
////            final String deviceSerial = call.argument("deviceSerial");
////            String verifyCode = call.argument("verifyCode");
////            final int cameraNo = call.argument("cameraNo");
////
////            final Calendar startCalendar = Calendar.getInstance();
////            startCalendar.setTimeInMillis(startTime);
////
////            final Calendar endCalendar = Calendar.getInstance();
////            endCalendar.setTimeInMillis(endTime);
////
////            final Looper looper = Looper.myLooper();
////            // Android 4.0 之后不能在主线程中请求HTTP请求
////            new Thread(new Runnable(){
////                @Override
////                public void run() {
////                    try {
////                        List<EZDeviceRecordFile> ezDeviceRecordFiles = EZOpenSDK.getInstance().searchRecordFileFromDevice(deviceSerial, cameraNo, startCalendar, endCalendar);
////                        // 发送消息给flutter
////                        final String jsonString = new Gson().toJson(ezDeviceRecordFiles);
////
////                        new Handler(looper).post(new Runnable() {
////                            @Override
////                            public void run() {
////                                Ys7ToFlutterEntity recordFile = new Ys7ToFlutterEntity("RecordFile", jsonString);
////                                recordFile.setCallBackFuncId(callBackFuncId);
////                                nativeToFlutterYs7.send(new Gson().toJson(recordFile));
////                            }
////                        });
////
////                    } catch (BaseException e) {
////                        e.printStackTrace();
////                    }
////                }
////            }).start();
////
////            result.success("success");
////
////        }
//
//
//    }

    @Nullable
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
}
