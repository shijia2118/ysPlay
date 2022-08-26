package com.example.hxjt.ys_play;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YsPlayViewFactory extends PlatformViewFactory {

    public YsPlayViewFactory(@NonNull BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        new MethodChannel(messenger, "ys_play");

    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId,  Object args) {
         Map<String, Object> params = (Map<String, Object>) args;
        String deviceSerial = (String) params.get("device_code");
        Integer cameraNo = (Integer) params.get("camera_no");
        if(cameraNo==null) cameraNo=-1;
        String verifyCode = (String) params.get("verify_code");

        return new YsPlayView(context,deviceSerial,verifyCode,cameraNo,null);
    }
}
