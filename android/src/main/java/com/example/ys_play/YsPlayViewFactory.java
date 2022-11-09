package com.example.ys_play;

import android.app.Application;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.example.ys_play.Interface.OnPlatformViewCreated;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YsPlayViewFactory extends PlatformViewFactory {
    final String TAG = "萤石LOG=========>";

    @NonNull private final BinaryMessenger messenger;
    private OnPlatformViewCreated onViewCreated;

    /// 构造函数，在应用启动时执行
    public YsPlayViewFactory(@NonNull BinaryMessenger messenger, Application application, OnPlatformViewCreated onViewCreated) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.onViewCreated = onViewCreated;
    }

    /// 创建视图
    /// flutter端调用androidView时执行
    @NonNull
    @Override
    public PlatformView create(Context context, int id, Object args) {
        Map<String, Object> creationParams = (Map<String, Object>) args;
        Log.i(TAG,""+creationParams);
        return new YsPlayView(context,onViewCreated);
    }
}
