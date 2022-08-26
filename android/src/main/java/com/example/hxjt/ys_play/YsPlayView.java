package com.example.hxjt.ys_play;

import android.content.Context;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.platform.PlatformView;

public class YsPlayView implements PlatformView{
    private SurfaceView surfaceView;
    private EZPlayer ezPlayer = null;
    String deviceSerial ;
    String verifyCode ;
    int cameraNo ;

    ///通过构造函数，获取相关参数值
    public YsPlayView(Context context,String deviceSerial,String verifyCode,int cameraNo,OnResult onResult){
        surfaceView = new SurfaceView(context);
        this.deviceSerial=deviceSerial;
        this.verifyCode=verifyCode;
        this.cameraNo=cameraNo;

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
        onResult.success(true);
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

}
