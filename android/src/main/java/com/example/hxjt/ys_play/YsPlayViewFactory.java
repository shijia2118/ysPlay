package com.example.hxjt.ys_play;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YsPlayViewFactory extends PlatformViewFactory {

    private final BinaryMessenger messenger;

    public YsPlayViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger=messenger;
        Log.i(">>>>>>>>>>","构造函数");
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Log.i(">>>>>>viewid1==",""+viewId);
        Map<String, Object> params = (Map<String, Object>) args;
        return new YsPlayView(context,messenger,viewId,params);
    }
}
