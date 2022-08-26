package com.example.hxjt.ys_play;

import android.content.Context;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class YsPlayView implements PlatformView, MethodChannel.MethodCallHandler {
    private SurfaceView surfaceView;
    private EZPlayer ezPlayer = null;
    String deviceSerial ;
    String verifyCode ;
    int cameraNo =-1;

    ///通过构造函数，获取相关参数值
    public YsPlayView(Context context, BinaryMessenger messenger, String id, Map<String, Object> params){
        surfaceView = new SurfaceView(context);
        Log.i(">>>>>>>","params=view="+params);
        if(params!=null){
            if(params.containsKey("device_code")){
                deviceSerial = (String) params.get("device_code");
            }
            if(params.containsKey("verify_code")){
                verifyCode = (String) params.get("verify_code");
            }
            if(params.containsKey("camera_no")){
                Integer cn = (Integer) params.get("camera_no");
                if(cn!=null) cameraNo=cn;
            }

        }


        ezPlayer = EZOpenSDK.getInstance().createPlayer(deviceSerial,cameraNo);
        ezPlayer.setHandler(new YsPlayViewHandler());
        ezPlayer.setSurfaceHold(surfaceView.getHolder());
        //设置播放器的surface
        surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(@NonNull SurfaceHolder surfaceHolder) {
                if (ezPlayer != null) {
                    ezPlayer.setSurfaceHold(surfaceHolder);
                }
            }

            @Override
            public void surfaceChanged(@NonNull SurfaceHolder surfaceHolder, int i, int i1, int i2) {

            }

            @Override
            public void surfaceDestroyed(@NonNull SurfaceHolder surfaceHolder) {
                if (ezPlayer != null) {
                    ezPlayer.setSurfaceHold(null);
                }
            }
        });
        ezPlayer.setPlayVerifyCode(verifyCode);
        MethodChannel methodChannel = new MethodChannel(messenger, ""+ id);
        methodChannel.setMethodCallHandler(this);
    }

    @Nullable
    @Override
    public View getView() {
        return surfaceView;
    }

    @Override
    public void dispose() {
        if(ezPlayer!=null) ezPlayer.release();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.i(">>>>>>>>","call.method:"+call.method+">>>>>>>"+"call.arguments:"+call.arguments);
        if(call.method.equals("create_player")){
            Log.i(">>>>>>>>>",">播放器初始化成功");
        }

    }
}
