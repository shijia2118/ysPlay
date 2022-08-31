package com.example.ys_play;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YsPlayViewFactory extends PlatformViewFactory {
//    final String TAG = "萤石LOG=========>";

    @NonNull private final BinaryMessenger messenger;
    @NonNull private final InitPlayerCallback playerCallback;

    public YsPlayViewFactory(@NonNull BinaryMessenger messenger,@NonNull InitPlayerCallback playerCallback) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.playerCallback = playerCallback;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int id, Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new YsPlayView(context, id, creationParams,this.messenger,playerCallback);
    }
}
