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

    public YsPlayView(@NonNull Context context,OnPlatformViewCreated onViewCreated){
        surfaceView = new SurfaceView(context);
        onViewCreated.callback(surfaceView);
    }

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
