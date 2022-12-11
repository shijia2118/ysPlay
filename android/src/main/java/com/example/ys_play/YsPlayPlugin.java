package com.example.ys_play;

import android.app.Application;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.example.ys_play.Entity.PeiwangResultEntity;
import com.example.ys_play.Entity.YsPlayerStatusEntity;
import com.example.ys_play.Interface.YsResultListener;
import com.example.ys_play.utils.LogUtils;
import com.example.ys_play.utils.TimeUtils;
import com.google.gson.Gson;
import com.videogo.exception.BaseException;
import com.videogo.openapi.EZConstants;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZOpenSDKListener;
import com.videogo.openapi.EZPlayer;
import com.videogo.openapi.bean.EZProbeDeviceInfoResult;
import com.videogo.wificonfig.APWifiConfig;

import java.util.Calendar;
import java.util.Objects;

import io.flutter.BuildConfig;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;

public class YsPlayPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

    private Application application;
    private EZPlayer ezPlayer;
    private EZPlayer talk;

    private SurfaceView surfaceView;
    BasicMessageChannel<Object> ysResult;
    BasicMessageChannel<Object> pwResult; //配网结果通道

    private String deviceSerial;
    private Integer cameraNo;
    private Integer supportTalk; //1-半双工 3-全双工
    private boolean isPhone2Dev; //true-手机端说，设备端听 false-设备端说，手机端听

    private YsPlayViewHandler mHandler;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        application = (Application) binding.getApplicationContext();
        BinaryMessenger messenger = binding.getBinaryMessenger();


        /// 注册播放视图
        binding.getPlatformViewRegistry().registerViewFactory(
                Constants.CHANNEL,
                new YsPlayViewFactory((surfaceView) -> {
                    this.surfaceView = surfaceView;
                    //设置播放器的显示Surface
                    surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
                        @Override
                        public void surfaceCreated(@NonNull SurfaceHolder holder) {
                            LogUtils.d("surfaceCreated");
                            if (ezPlayer != null) {
                                ezPlayer.setSurfaceHold(holder);
                            }
                        }

                        @Override
                        public void surfaceChanged(@NonNull SurfaceHolder holder, int format, int width, int height) {
                            LogUtils.d("surfaceChanged");
                        }

                        @Override
                        public void surfaceDestroyed(@NonNull SurfaceHolder holder) {
                            LogUtils.d("surfaceDestroyed");
                            if (ezPlayer != null) {
                                ezPlayer.setSurfaceHold(null);
                            }
                        }
                    });
                })
        );

        ///建立flutter和android端的通信通道
        new MethodChannel(messenger, Constants.CHANNEL).setMethodCallHandler(this);

        /// 播放器状态改变时，传递消息到flutter端
        ysResult =  new BasicMessageChannel<>(messenger, Constants.PLAYER_STATUS_CHANNEL, new StandardMessageCodec());

        /// 配网结果改变时，传递消息给flutter端
        pwResult =  new BasicMessageChannel<>(messenger, Constants.PEI_WANG_CHANNEL, new StandardMessageCodec());

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "init_sdk":
                EZOpenSDK.showSDKLog(BuildConfig.DEBUG);
                String appKey = call.argument("appKey");
                boolean initResult = EZOpenSDK.initLib(this.application, appKey);
                LogUtils.d("初始化"+(initResult?"成功":"失败"));

                result.success(initResult);
                break;
            case "set_access_token":
                String accessToken = call.argument("accessToken");
                EZOpenSDK.getInstance().setAccessToken(accessToken);
                LogUtils.d("token设置成功");
                result.success(true);
                break;
            case "destroyLib":
                /// 销毁萤石SDK
                EZOpenSDK.finiLib();
                break;
            case "EZPlayer_init":
                //初始化播放器
                deviceSerial = call.argument("deviceSerial");
                String verifyCode = call.argument("verifyCode");
                cameraNo = call.argument("cameraNo");
                if(cameraNo==null) cameraNo=1;

                ezPlayer  = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);

                mHandler = new YsPlayViewHandler(ysResultListener);
                ezPlayer.setHandler(mHandler);
                ezPlayer.setSurfaceHold(surfaceView.getHolder());
                ezPlayer.setPlayVerifyCode(verifyCode);
                LogUtils.d("播放器初始化成功");
                result.success(true);
                break;
            case "startPlayback":
                ///开启回放
                if(ezPlayer==null) return;
                if(call.hasArgument("startTime")&&call.hasArgument("endTime")){
                    Long startTime = call.argument("startTime");
                    Long endTime = call.argument("endTime");
                    if(startTime==null||endTime==null){
                        LogUtils.d("startTime或endTime均不能为空");
                        result.success(false);
                    }else{
                        final Calendar startCalendar = Calendar.getInstance();
                        startCalendar.setTimeInMillis(startTime);
                        final Calendar endCalendar = Calendar.getInstance();
                        endCalendar.setTimeInMillis(endTime);
                        boolean isSuccess = ezPlayer.startPlayback(startCalendar, endCalendar);
                        LogUtils.d("开启回放"+(isSuccess?"成功":"失败"));
                        result.success(isSuccess);
                    }
                }else {
                    LogUtils.d("startTime或endTime均不能为空");
                    result.success(false);
                }
                break;
            case "pause_play_back":
                /// 暂停回放
                if(ezPlayer==null) return;
                boolean isPause = ezPlayer.pausePlayback();
                LogUtils.d("暂停回放"+(isPause?"成功":"失败"));
                result.success(isPause);
                break;
            case "resume_play_back":
                /// 恢复回放
                if(ezPlayer==null) return;
                boolean isResume = ezPlayer.resumePlayback();
                LogUtils.d("恢复回放"+(isResume?"成功":"失败"));
                result.success(isResume);
                break;
            case "stopPlayback":
                 /// 停止回放
                if(ezPlayer==null) return;
                boolean isSuccess = ezPlayer.stopPlayback();
                LogUtils.d("停止回放"+(isSuccess?"成功":"失败"));
                result.success(isSuccess);
                 break;
            case "startRealPlay":
                ///开启直播
                if(ezPlayer!=null){
                    boolean realStartResult = ezPlayer.startRealPlay();
                    LogUtils.d("开始直播"+(realStartResult?"成功":"失败"));
                    result.success(realStartResult);
                }else{
                    LogUtils.d("ezPlayer不能为空");
                    result.success(false);
                }
                break;
            case "stopRealPlay":
                ///停止直播
                if(ezPlayer==null) return;
                boolean stopRealResult = ezPlayer.stopRealPlay();
                LogUtils.d("停止直播"+(stopRealResult?"成功":"失败"));
                result.success(stopRealResult);
                break;
            case "openSound":
                /// 打开声音
                if(ezPlayer==null) return;
                boolean openResult = ezPlayer.openSound();
                result.success(openResult);
                break;
            case "closeSound":
                /// 关闭声音
                if(ezPlayer==null) return;
                boolean closeResult = ezPlayer.closeSound();
                result.success(closeResult);
                break;
            case "capturePicture":
                /// 截屏
                if(ezPlayer==null) return;
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        String fileName = Environment.getExternalStorageDirectory().getPath() + "/DCIM/" + TimeUtils.dateToString(TimeUtils.getTimeStame(), "yyyyMMddHHmmss") + ".png";
                        int captureResult = ezPlayer.capturePicture(fileName);
                        if(captureResult==0){
                            application.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + fileName)));
                        }
                        result.success(captureResult==0);
                    }
                }).start();
                break;

            case "release":
                /// 释放资源
                if(ezPlayer!=null){
                    ezPlayer.setSurfaceHold(null);
                    surfaceView=null;
                    mHandler = null;
                    ezPlayer.release();
                }
                if(talk != null){
                    mHandler = null;
                    talk.release();
                }
                break;
            case "start_record":
                /// 开始录像前，先结束本地直播流录像
                if(ezPlayer==null) return;
                ezPlayer.stopLocalRecord();
                String recordFile = Environment.getExternalStorageDirectory().getPath() + "/DCIM/" + TimeUtils.dateToString(TimeUtils.getTimeStame(), "yyyyMMddHHmmss") + ".mp4";

                boolean recordResult = ezPlayer.startLocalRecordWithFile(recordFile);
                LogUtils.d("开启录像"+(recordResult?"成功":"失败"));
                if(recordResult){
                    application.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + recordFile)));
                }
                result.success(recordResult);
                break;
            case "stop_record":
                /// 停止录像
                if(ezPlayer==null) return;
                boolean stopRecordResult = ezPlayer.stopLocalRecord();
                LogUtils.d("停止录像"+(stopRecordResult?"成功":"失败"));
                result.success(stopRecordResult);
                break;
            case "set_video_level":
                /// 设置视频清晰度
                /// videoLevel – 清晰度 0-流畅 1-均衡 2-高品质
                if(call.hasArgument("deviceSerial")
                        &&call.hasArgument("cameraNo")
                        &&call.hasArgument("videoLevel")){
                   String deviceSerial = call.argument("deviceSerial");
                   Integer cameraNo = call.argument("cameraNo");
                   if(cameraNo==null) cameraNo=1;
                   Integer videoLevel = call.argument("videoLevel");
                   if(videoLevel==null) videoLevel=2;

                   if(deviceSerial != null){
                       Integer finalCameraNo = cameraNo;
                       Integer finalVideoLevel = videoLevel;
                       new Thread(){
                           public void run(){
                               Looper.prepare();
                               new Handler().post(new Runnable() {
                                   @Override
                                   public void run() {
                                       try {
                                           boolean vlResult =  EZOpenSDK.getInstance().setVideoLevel(deviceSerial, finalCameraNo, finalVideoLevel);
                                           result.success(vlResult);
                                       } catch ( BaseException e) {
                                           LogUtils.d(""+e);
                                           Toast.makeText(application, e.toString(), Toast.LENGTH_SHORT).show();
                                           result.success(false);
                                       }
                                   }
                               });
                               Looper.loop();
                           }
                       }.start();
                    }
                }
                break;
            case "start_config_wifi":
                /*
                 * 开始WiFi配置
                 * @since 4.8.3
                 * @param context  应用 activity context
                 * @param deviceSerial   配置设备序列号
                 * @param ssid  连接WiFi SSID
                 * @param password  连接  WiFi 密码
                 * @param mode      配网的方式，EZWiFiConfigMode中列举的模式进行任意组合
                 *                  EZWiFiConfigMode.EZWiFiConfigSmart:普通配网(WiFi)；
                 *                  EZWiFiConfigMode.EZWiFiConfigWave：声波配网(Wave)
                 * @param back     配置回调
                 */
                deviceSerial = call.argument("deviceSerial");
                String ssid = call.argument("ssid");
                String password = call.argument("password");
                String mode = call.argument("mode");
                int configMode=EZConstants.EZWiFiConfigMode.EZWiFiConfigSmart;//默认wifi配网
                if(Objects.equals(mode,"wave")){
                    // 声波配网
                    configMode = EZConstants.EZWiFiConfigMode.EZWiFiConfigWave;
                }
                EZOpenSDK.getInstance().startConfigWifi(
                        application.getApplicationContext(),
                        deviceSerial,
                        ssid,
                        password,
                        configMode,
                        mEZStartConfigWifiCallback
                );
                break;
            case "start_config_ap":
                /*
                 * AP配网接口(热点配网)
                 * @param ssid WiFi的ssid
                 * @param password WiFi的密码
                 * @param deviceSerial 设备序列号
                 * @param verifyCode 设备验证码
                 * @param routerName 设备热点名称，可传空，默认为"EZVIZ_"+设备序列号
                 * @param routerPassword 设备热点密码,可传空，默认为"EZVIZ_"+设备验证码
                 * @param isAutoConnectDeviceHotSpot 是否自动连接设备热点,需要获取可扫描wifi的权限；如果开发者已经确认手机连接到设备热点，则传false
                 * @param apConfigCallback 结果回调
                 */
                ssid = call.argument("ssid");
                password = call.argument("password");
                deviceSerial = call.argument("deviceSerial");
                verifyCode = call.argument("verifyCode");

                EZOpenSDK.getInstance().startAPConfigWifiWithSsid(
                        ssid,
                        password,
                        deviceSerial,
                        verifyCode,
                        "EZVIZ_"+deviceSerial,
                "EZVIZ_"+ verifyCode,
                 true,
                        apConfigCallback
                );
                break;
            case "stop_config":
                mode = call.argument("mode");
                if(Objects.equals(mode, "wave") || Objects.equals(mode, "wifi")){
                  boolean stopConfigResult =  EZOpenSDK.getInstance().stopConfigWiFi();
                    LogUtils.d("停止配网:"+(stopConfigResult?"成功":"失败"));
                    result.success(stopConfigResult);
                }else if(Objects.equals(mode,"ap")){
                    //热点
                    EZOpenSDK.getInstance().stopAPConfigWifiWithSsid();
                    LogUtils.d("停止配网:成功");
                    result.success(true);
                }else{
                    result.success(false);
                }
                break;
            case "start_voice_talk": /// 开始对讲
                if (talk != null) {
                    //关闭播放声音
                    ezPlayer.closeSound();
                    //关闭对讲
                    talk.stopVoiceTalk();
                    //销毁对讲器
                    talk.release();
                }
                deviceSerial = call.argument("deviceSerial");
                verifyCode = call.argument("verifyCode");
                cameraNo = call.argument("cameraNo");
                supportTalk = call.argument("supportTalk");
                isPhone2Dev = Boolean.TRUE.equals(call.argument("isPhone2Dev"));
                if(cameraNo==null) cameraNo=1;
                if(supportTalk==null) supportTalk = 1;

                talk = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);
                //设置Handler, 该handler将被用于从播放器向handler传递消息
                if(mHandler==null){
                    mHandler = new YsPlayViewHandler(ysResultListener);
                }
                talk.setHandler(mHandler);
                //设备加密的需要传入密码
                talk.setPlayVerifyCode(verifyCode);
                //开启对讲
                talk.startVoiceTalk();
        
                if(!isPhone2Dev){
                    //声音开关
                    ezPlayer.openSound();
                    //手机端听，设备端说
                    talk.setVoiceTalkStatus(false);
                    talk.stopVoiceTalk();
                }
                break;
            case "stop_voice_talk": /// 停止对讲
                if(talk != null){
                    isSuccess = talk.stopVoiceTalk();
                    LogUtils.d("停止对讲"+(isSuccess?"成功":"失败"));
                    talk.release();
                    result.success(isSuccess);
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * 播放器状态监听回调
     */
    YsResultListener ysResultListener = new YsResultListener() {
        @Override
        public void onPlaySuccess() {
            YsPlayerStatusEntity entity = new YsPlayerStatusEntity();
            entity.setIsSuccess(true);
            ysResult.send(new Gson().toJson(entity));
        }

        @Override
        public void onTalkSuccess() {
            if(talk!=null) {
                //半双工
                if(supportTalk != null && supportTalk == 3){
                    //设备端听，手机端说
                    talk.setVoiceTalkStatus(isPhone2Dev);
                }
            }
        }

        @Override
        public void onPlayError(String errorInfo) {
            YsPlayerStatusEntity entity = new YsPlayerStatusEntity();
            entity.setIsSuccess(false);
            entity.setPlayErrorInfo(errorInfo);
            ysResult.send(new Gson().toJson(entity));
        }

        @Override
        public void onTalkError(String errorInfo) {
            YsPlayerStatusEntity entity = new YsPlayerStatusEntity();
            entity.setIsSuccess(false);
            entity.setTalkErrorInfo(errorInfo);
            ysResult.send(new Gson().toJson(entity));
        }
    };

    /**
     * 配网回调
     */
    EZOpenSDKListener.EZStartConfigWifiCallback mEZStartConfigWifiCallback =
            new EZOpenSDKListener.EZStartConfigWifiCallback() {
                @Override
                public void onStartConfigWifiCallback(String deviceSerial, EZConstants.EZWifiConfigStatus status) {
                    new Thread(){
                        public void run(){
                            new Handler(Looper.getMainLooper()).post(new Runnable() {
                                @Override
                                public void run() {
                                    PeiwangResultEntity entity = new PeiwangResultEntity();
                                    if (status == EZConstants.EZWifiConfigStatus.DEVICE_WIFI_CONNECTED) {
                                        //设备wifi连接成功
                                        //停止Wifi配置
                                        entity.setIsSuccess(true);
                                        entity.setMsg("设备WiFi连接成功");
                                    } else if (status == EZConstants.EZWifiConfigStatus.DEVICE_PLATFORM_REGISTED) {
                                        //停止Wifi配置
                                        //设备注册到平台成功，可以调用添加设备接口添加设备
                                        entity.setIsSuccess(true);
                                        entity.setMsg("设备注册成功");
                                    } else {
                                        //停止Wifi配置
                                        entity.setIsSuccess(false);
                                        entity.setMsg(status.description);
                                    }
                                    EZOpenSDK.getInstance().stopConfigWiFi();
                                    pwResult.send(new Gson().toJson(entity));
                                };
                            });
                        }
                    }.start();
                }
            };

    /// AP配网结果回调
    APWifiConfig.APConfigCallback apConfigCallback = new APWifiConfig.APConfigCallback() {
        @Override
        public void onSuccess() {
            // TODO: 2018/6/28 配网成功
            new Thread(){
                public void run(){
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            LogUtils.d("配网成功");
                            PeiwangResultEntity entity = new PeiwangResultEntity();
                            entity.setIsSuccess(true);
                            entity.setMsg("热点配网成功");
                            pwResult.send(new Gson().toJson(entity));
                            EZOpenSDK.getInstance().stopAPConfigWifiWithSsid();
                        };
                    });
                }
            }.start();
        }

//        @Override
//        public void reportInfo(EZConfigWifiInfoEnum info) {
//            super.reportInfo(info);
//            if (info == EZConfigWifiInfoEnum.CONNECTED_TO_PLATFORM) {
//                onSuccess();
//            }
//        }

        @Override
        public void OnError(int code) {
            // TODO: 2018/6/28 配网失败
            new Thread(){
                public void run(){
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            LogUtils.d("配网失败");
                            PeiwangResultEntity entity = new PeiwangResultEntity();
                            entity.setIsSuccess(false);
                            switch (code) {
                                case 15:
                                    // TODO: 2018/7/24 超时
                                    entity.setMsg("配网超时");
                                    break;
                                case 1:
                                    // TODO: 2018/7/24 参数错误
                                    entity.setMsg("参数错误");
                                    break;
                                case 2:
                                    // TODO: 2018/7/24 设备ap热点密码错误
                                    entity.setMsg("设备ap热点密码错误");
                                    break;
                                case 3:
                                    // TODO: 2018/7/24  连接ap热点异常
                                    entity.setMsg("连接ap热点异常");
                                    break;
                                case 4:
                                    // TODO: 2018/7/24 搜索WiFi热点错误
                                    entity.setMsg("搜索WiFi热点错误");
                                    break;
                                default:
                                    // TODO: 2018/7/24 未知错误
                                    entity.setMsg("未知错误:"+code);
                                    // 更多错误码请见枚举类 EZConfigWifiErrorEnum 相关说明
                                    break;
                            }
                            pwResult.send(new Gson().toJson(entity));
                            EZOpenSDK.getInstance().stopAPConfigWifiWithSsid();
                        };
                    });
                }
            }.start();
        }
    };


}
