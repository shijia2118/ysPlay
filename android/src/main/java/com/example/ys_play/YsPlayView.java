package com.example.ys_play;

import android.content.Context;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.ys_play.Interface.OnPlatformViewCreated;
import io.flutter.plugin.platform.PlatformView;

public class YsPlayView implements PlatformView{

    private TextureView textureView;

    public YsPlayView(@NonNull Context context,OnPlatformViewCreated onViewCreated){
        textureView = new TextureView(context);
        onViewCreated.callback(textureView); //把 textureView 回调给 YsPlayPlugin
    }

    @Nullable
    @Override
    public View getView() {
        return textureView;
    }

    @Override
    public void dispose() {
        textureView=null;
    }
}
