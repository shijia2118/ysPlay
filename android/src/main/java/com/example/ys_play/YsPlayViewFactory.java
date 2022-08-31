package com.example.ys_play;

import android.app.Application;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.videogo.openapi.EZOpenSDK;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YsPlayViewFactory extends PlatformViewFactory  implements MethodChannel.MethodCallHandler {
    final String TAG = "萤石LOG=========>";

    @NonNull private final BinaryMessenger messenger;
    private final Application application;

    public YsPlayViewFactory(@NonNull BinaryMessenger messenger,Application application) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.application = application;

        new MethodChannel(messenger, Constants.CHANNEL).setMethodCallHandler(this);
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int id, Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new YsPlayView(context, id, creationParams,this.messenger,application);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "init_sdk":
                //初始化sdk
                String appKey = call.argument("appKey");
                boolean value = EZOpenSDK.initLib(this.application, appKey);
                Log.d(TAG, "sdk初始化结果:" + value);
                result.success(value);
                break;
            case "set_access_token":
                //绑定账号
                String AccessToken = call.argument("accessToken");
                EZOpenSDK.getInstance().setAccessToken(AccessToken);
                result.success(true);
                break;
            case "destoryLib":
                //释放sdk资源
                EZOpenSDK.finiLib();
                result.success(true);
                break;
            default:
                result.notImplemented();
                break;
        }

    }
}
