package com.example.ys_play;

import android.content.Context;

import androidx.annotation.NonNull;

import com.example.ys_play.Interface.OnPlatformViewCreated;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YsPlayViewFactory extends PlatformViewFactory {

    private final OnPlatformViewCreated onViewCreated;

    ///应用启动时，通过registerViewFactory方法调用1次
    public YsPlayViewFactory(OnPlatformViewCreated onViewCreated) {
        super(StandardMessageCodec.INSTANCE);
        this.onViewCreated = onViewCreated;
    }

    /// 创建视图
    /// flutter端每次调用androidView时，都会执行1次
    @NonNull
    @Override
    public PlatformView create(Context context, int id, Object args) {
        return new YsPlayView(context,onViewCreated);
    }
}
