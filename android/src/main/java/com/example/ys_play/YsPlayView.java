package com.example.ys_play;

import android.content.Context;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class YsPlayView implements PlatformView{
    private final SurfaceView surfaceView;
    private final EZPlayer ezPlayer;
    private String deviceSerial;
    private String verifyCode;
    Integer cameraNo;

    public YsPlayView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams,OnSurfaceViewCreated onSurfaceViewCreated) {
        surfaceView = new SurfaceView(context);
        if(creationParams !=null){
            if(creationParams.containsKey("deviceSerial")){
                deviceSerial=(String) creationParams.get("deviceSerial");
            }
            if(creationParams.containsKey("verifyCode")){
                verifyCode=(String) creationParams.get("verifyCode");
            }
            if(creationParams.containsKey("cameraNo")){
                cameraNo = (Integer)creationParams.get("cameraNo");
                if(cameraNo==null) cameraNo = -1;
            }
        }
        Log.i(">>>>>>>>createparams===",""+creationParams);
        ezPlayer  = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);

        ezPlayer.setHandler(new YsPlayViewHandler());
        ezPlayer.setSurfaceHold(surfaceView.getHolder());
        //设置播放器的显示Surface
        surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(@NonNull SurfaceHolder holder) {
                ezPlayer.setSurfaceHold(holder);
            }

            @Override
            public void surfaceChanged(@NonNull SurfaceHolder holder, int format, int width, int height) {

            }

            @Override
            public void surfaceDestroyed(@NonNull SurfaceHolder holder) {
                ezPlayer.setSurfaceHold(null);

            }
        });
        ezPlayer.setSurfaceHold(surfaceView.getHolder());

        ezPlayer.setPlayVerifyCode(verifyCode);
        Log.i(">>>>>>>>",">>>>>>onsuerface");

        if(onSurfaceViewCreated!=null){
            onSurfaceViewCreated.createPlayer(ezPlayer);
            onSurfaceViewCreated.result(true);
        }

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



}
