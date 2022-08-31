package com.example.ys_play;

import android.content.Context;
import android.os.Looper;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.ys_play.Entity.InitPlayerEntity;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;
import java.util.Map;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;

public class YsPlayView implements PlatformView {

    private SurfaceView surfaceView = null;
    private EZPlayer ezPlayer = null;
    BasicMessageChannel<Object> nativeToFlutter;

    @NonNull InitPlayerCallback playerCallback;

    private String deviceSerial;
    private String verifyCode;
    private Integer cameraNo;

    private final InitPlayerEntity initPlayerEntity = new InitPlayerEntity();

    public YsPlayView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams, BinaryMessenger messenger,@NonNull InitPlayerCallback playerCallback) {
        this.playerCallback = playerCallback;

        nativeToFlutter = new BasicMessageChannel<>(messenger, "nativeToFlutter", new StandardMessageCodec());
        surfaceView = new SurfaceView(context);
        Log.i(">>>>>>>","param1=="+creationParams);

        if(creationParams!=null){
            if(creationParams.containsKey("deviceSerial")){
                deviceSerial = (String) creationParams.get("deviceSerial");
            }
            if(creationParams.containsKey("verifyCode")){
                verifyCode = (String) creationParams.get("verifyCode");
            }
            if(creationParams.containsKey("cameraNo")){
                cameraNo = (Integer) creationParams.get("cameraNo");
            }
            if(cameraNo==null) cameraNo=-1;

            ezPlayer  = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);
            ezPlayer.setHandler(new YsPlayViewHandler(Looper.getMainLooper()));
            ezPlayer.setSurfaceHold(surfaceView.getHolder());
            ezPlayer.setPlayVerifyCode(verifyCode);

            //设置播放器的显示Surface
            surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
                @Override
                public void surfaceCreated(@NonNull SurfaceHolder surfaceHolder) {
                    if(ezPlayer!=null){
                        initPlayerEntity.setPlayer(ezPlayer);
                        playerCallback.data(initPlayerEntity);
                        Log.i(">>>>>>>","ezplayer=="+initPlayerEntity.getPlayer());
                    }
                }

                @Override
                public void surfaceChanged(@NonNull SurfaceHolder surfaceHolder, int i, int i1, int i2) {
                    if(ezPlayer!=null){
                        initPlayerEntity.setPlayer(ezPlayer);
                        playerCallback.data(initPlayerEntity);
                    }
                }

                @Override
                public void surfaceDestroyed(@NonNull SurfaceHolder surfaceHolder) {
                    if (ezPlayer != null) {
                        ezPlayer.setSurfaceHold(null);
                    }
                }
            });

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
