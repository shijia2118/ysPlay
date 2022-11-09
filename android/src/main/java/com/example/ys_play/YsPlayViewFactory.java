package com.example.ys_play;

import android.content.Context;

import androidx.annotation.NonNull;

import com.example.ys_play.Interface.OnPlatformViewCreated;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YsPlayViewFactory extends PlatformViewFactory {
    final String TAG = "萤石LOG=========>";
    private final OnPlatformViewCreated onViewCreated;

    /// 构造函数，在应用启动时执行
    public YsPlayViewFactory(OnPlatformViewCreated onViewCreated) {
        super(StandardMessageCodec.INSTANCE);
        this.onViewCreated = onViewCreated;
    }

    /// 创建视图
    /// flutter端调用androidView时执行
    @NonNull
    @Override
    public PlatformView create(Context context, int id, Object args) {
        return new YsPlayView(context,onViewCreated);
    }
}
