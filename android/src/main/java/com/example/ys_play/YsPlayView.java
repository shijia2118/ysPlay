package com.example.ys_play;

import android.content.Context;
import android.view.SurfaceView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.ys_play.Interface.OnPlatformViewCreated;
import io.flutter.plugin.platform.PlatformView;

public class YsPlayView implements PlatformView{

    private SurfaceView surfaceView;

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
        surfaceView=null;
    }
}
