package com.example.ys_play;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YsPlayViewFactory extends PlatformViewFactory{
    OnSurfaceViewCreated onSurfaceViewCreated;

    public YsPlayViewFactory(@NonNull BinaryMessenger messenger,OnSurfaceViewCreated onSurfaceViewCreated) {
        super(StandardMessageCodec.INSTANCE);
        this.onSurfaceViewCreated=onSurfaceViewCreated;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int id, Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new YsPlayView(context, id, creationParams,onSurfaceViewCreated);
    }

}
