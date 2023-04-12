package com.example.ys_play;

import android.app.Application;
import android.content.Intent;
import android.graphics.SurfaceTexture;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.view.TextureView;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.example.ys_play.Entity.PeiwangResultEntity;
import com.example.ys_play.Entity.YsPlayerStatusEntity;
import com.example.ys_play.Interface.YsResultListener;
import com.example.ys_play.utils.LogUtils;
import com.example.ys_play.utils.TimeUtils;
import com.ezviz.sdk.configwifi.EZConfigWifiErrorEnum;
import com.ezviz.sdk.configwifi.EZConfigWifiInfoEnum;
import com.google.gson.Gson;
import com.videogo.exception.BaseException;
import com.videogo.openapi.EZConstants;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZOpenSDKListener;
import com.videogo.openapi.EZPlayer;
import com.videogo.openapi.bean.EZStorageStatus;
import com.videogo.wificonfig.APWifiConfig;

import java.util.Calendar;
import java.util.List;
import java.util.Objects;

import io.flutter.BuildConfig;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;

public class YsPlayPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler,TextureView.SurfaceTextureListener{

    private Application application;
    private EZPlayer ezPlayer; //视频播放器
    private EZPlayer talkPlayer; //对讲播放器

    private TextureView textureView; //播放视图
    BasicMessageChannel<Object> ysResult; //回放、直播和对讲结果渠道
    BasicMessageChannel<Object> pwResult; //配网结果通道

    private Integer supportTalk; //0-不支持 1-全双工 3-半双工
    private Integer isPhone2Dev; //0-设备端说，手机端听;1-手机端说，设备端听;

    private Integer partitionIndex; //摄像头分区编号

    /**
     * 插件初始化
     * 当且仅当应用启动时，插件注册完成后执行。
     * @param binding:可以获取上下文内容，messenger等
     */

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        application = (Application) binding.getApplicationContext();
        BinaryMessenger messenger = binding.getBinaryMessenger();
        /// 注册播放视图
        binding.getPlatformViewRegistry().registerViewFactory(
                Constants.CHANNEL,
                new YsPlayViewFactory((textureView) -> {
                    LogUtils.d(""+this.textureView);
                    this.textureView = textureView;
                    //设置播放器的显示Surface
                    textureView.setSurfaceTextureListener(this);
                })
        );

        ///建立flutter和android端的通信通道
        new MethodChannel(messenger, Constants.CHANNEL).setMethodCallHandler(this);

        ///播放器状态改变时，传递消息到flutter端
        ysResult =  new BasicMessageChannel<>(messenger, Constants.PLAYER_STATUS_CHANNEL, new StandardMessageCodec());

        ///配网结果改变时，传递消息给flutter端
        pwResult =  new BasicMessageChannel<>(messenger, Constants.PEI_WANG_CHANNEL, new StandardMessageCodec());

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            /// 初始化萤石SDK
            case "init_sdk":
                EZOpenSDK.showSDKLog(BuildConfig.DEBUG);
                String appKey = call.argument("appKey");
                boolean initResult = EZOpenSDK.initLib(this.application, appKey);
                LogUtils.d("萤石SDK初始化"+(initResult?"成功":"失败"));
                result.success(initResult);
                break;
            /// 设置accessToken
            case "set_access_token":
                String accessToken = call.argument("accessToken");
                EZOpenSDK.getInstance().setAccessToken(accessToken);
                LogUtils.d("token设置成功");
                result.success(true);
                break;
            /// 开启回放
            case "startPlayback":
                if(ezPlayer != null){
                    //先停止
                    ezPlayer.stopPlayback();
                    ezPlayer = null;
                }
                //flutter端的传参
                String deviceSerial = call.argument("deviceSerial");
                String verifyCode = call.argument("verifyCode");
                Integer cameraNo = call.argument("cameraNo");
                Long startTime = call.argument("startTime");
                Long endTime = call.argument("endTime");

                //初始化播放器
                ezPlayer = initEzPlayer(deviceSerial,verifyCode,cameraNo);

                if(startTime != null && endTime != null){
                    final Calendar startCalendar = Calendar.getInstance();
                    startCalendar.setTimeInMillis(startTime);
                    final Calendar endCalendar = Calendar.getInstance();
                    endCalendar.setTimeInMillis(endTime);
                    boolean isSuccess = ezPlayer.startPlayback(startCalendar, endCalendar);
                    LogUtils.d("开启回放"+(isSuccess?"成功":"失败"));
                    result.success(isSuccess);
                }else{
                    LogUtils.d("startTime或endTime均不能为空");
                    result.success(false);
                }
                break;
            /// 暂停回放
            case "pause_play_back":
                if(ezPlayer != null){
                    boolean isPause = ezPlayer.pausePlayback();
                    LogUtils.d("暂停回放"+(isPause?"成功":"失败"));
                    result.success(isPause);
                }else {
                    result.success(false);
                }
                break;
            /// 恢复回放
            case "resume_play_back":
                if(ezPlayer != null){
                    boolean isResume = ezPlayer.resumePlayback();
                    LogUtils.d("恢复回放"+(isResume?"成功":"失败"));
                    result.success(isResume);
                }else {
                    result.success(false);
                }
                break;
            /// 停止回放
            case "stopPlayback":
                if(ezPlayer != null){
                    boolean isSuccess = ezPlayer.stopPlayback();
                    LogUtils.d("停止回放"+(isSuccess?"成功":"失败"));
                    result.success(isSuccess);
                } else {
                    result.success(false);
                }
                 break;
            /// 开启直播
            case "startRealPlay":
                if(ezPlayer != null){
                    //先停止
                    ezPlayer.stopRealPlay();
                    ezPlayer = null;
                }
                //flutter端的传参
                deviceSerial = call.argument("deviceSerial");
                verifyCode = call.argument("verifyCode");
                cameraNo = call.argument("cameraNo");

                //注册播放器
                ezPlayer = initEzPlayer(deviceSerial,verifyCode,cameraNo);

                boolean realResult = ezPlayer.startRealPlay();
                LogUtils.d("开始直播"+(realResult?"成功":"失败"));
                result.success(realResult);
                break;
            /// 停止直播
            case "stopRealPlay":
                if(ezPlayer != null){
                    boolean stopRealResult = ezPlayer.stopRealPlay();
                    LogUtils.d("停止直播"+(stopRealResult?"成功":"失败"));
                    result.success(stopRealResult);
                } else {
                    result.success(false);
                }
                break;
            /// 打开声音
            case "openSound":
                if(ezPlayer==null) return;
                boolean openResult = ezPlayer.openSound();
                result.success(openResult);
                break;
            /// 关闭声音
            case "closeSound":
                if(ezPlayer==null) return;
                boolean closeResult = ezPlayer.closeSound();
                result.success(closeResult);
                break;
            /// 截屏
            case "capturePicture":
                if(ezPlayer==null) return;
                new Thread(() -> {
                    //图片保存路径
                    String filePath = Environment.getExternalStorageDirectory().getPath() + "/DCIM/" +
                            TimeUtils.dateToString(TimeUtils.getTimeStame(), "yyyyMMddHHmmss") + ".png";
                    int captureResult = ezPlayer.capturePicture(filePath);
                    if(captureResult==0){
                        // 刷新相册
                        application.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + filePath)));
                    }
                    result.success(captureResult==0);
                }).start();
                break;
            /// 开始录像
            case "start_record":
                if(ezPlayer==null) return;
                // 先结束本地直播流录像
                ezPlayer.stopLocalRecord();

                // 视频保存路径
                String recordFile = Environment.getExternalStorageDirectory().getPath()
                        + "/DCIM/" + TimeUtils.dateToString(TimeUtils.getTimeStame(), "yyyyMMddHHmmss") + ".mp4";

                ezPlayer.setStreamDownloadCallback(new EZOpenSDKListener.EZStreamDownloadCallback() {
                    @Override
                    public void onSuccess(String filepath) {
                        // 发送广播，通知刷新图库的显示
                        application.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + recordFile)));
                    }

                    @Override
                    public void onError(EZOpenSDKListener.EZStreamDownloadError code) {
                        LogUtils.d(code.name());
                    }
                });
                boolean recordResult = ezPlayer.startLocalRecordWithFile(recordFile);
                result.success(recordResult);
                break;
            /// 停止录像
            case "stop_record":
                if(ezPlayer==null) return;
                boolean stopRecordResult = ezPlayer.stopLocalRecord();
                LogUtils.d("停止录像"+(stopRecordResult?"成功":"失败"));
                result.success(stopRecordResult);
                break;
            /// 设置视频清晰度
            /// videoLevel: 0-流畅 1-均衡 2-高品质
            case "set_video_level":
                deviceSerial = call.argument("deviceSerial");
                cameraNo = call.argument("cameraNo");
                Integer videoLevel = call.argument("videoLevel");
                if(cameraNo==null) cameraNo=1;
                if(videoLevel==null) videoLevel=2;

                Integer finalCameraNo = cameraNo;
                Integer finalVideoLevel = videoLevel;
                new Thread(){
                    public void run(){
                        Looper.prepare();
                        new Handler().post(() -> {
                            try {
                                boolean vlResult =  EZOpenSDK.getInstance().setVideoLevel(deviceSerial, finalCameraNo, finalVideoLevel);
                                result.success(vlResult);
                            } catch ( BaseException e) {
                                LogUtils.d(""+e);
                                Toast.makeText(application, e.toString(), Toast.LENGTH_SHORT).show();
                                result.success(false);
                            }
                        });
                        Looper.loop();
                    }
                }.start();
                break;
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
            case "start_config_wifi":
                deviceSerial = call.argument("deviceSerial");
                String ssid = call.argument("ssid");
                String password = call.argument("password");
                String mode = call.argument("mode");
                int configMode=EZConstants.EZWiFiConfigMode.EZWiFiConfigSmart;//默认wifi配网
                if(Objects.equals(mode,"wave")){
                    //声波配网
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
            case "start_config_ap":
                ssid = call.argument("ssid");
                password = call.argument("password");
                deviceSerial = call.argument("deviceSerial");
                verifyCode = call.argument("verifyCode");

                EZOpenSDK.getInstance().startAPConfigWifiWithSsid(
                        ssid,
                        password,
                        deviceSerial,
                        verifyCode,
                        "EZVIZ_"+ deviceSerial,
                "EZVIZ_"+ verifyCode,
                 true,
                        apConfigCallback
                );
                break;

            ///停止配网
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

            ///开始对讲
            case "start_voice_talk":
                //关闭播放器声音
                if(ezPlayer!=null) ezPlayer.closeSound();
                //获取对讲参数
                deviceSerial = call.argument("deviceSerial");
                verifyCode = call.argument("verifyCode");
                cameraNo = call.argument("cameraNo");
                supportTalk = call.argument("supportTalk");
                isPhone2Dev = call.argument("isPhone2Dev");
                if(cameraNo ==null) cameraNo =1;
                if(supportTalk==null) supportTalk = 0;
                if(isPhone2Dev==null) isPhone2Dev = 1;

                if(talkPlayer == null) {
                    talkPlayer = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);
                    //设置Handler, 该handler将被用于从播放器向handler传递消息
                    talkPlayer.setHandler(new YsPlayViewHandler(ysResultListener));
                    //设备加密的需要传入密码
                    talkPlayer.setPlayVerifyCode(verifyCode);
                }else{
                    talkPlayer.stopVoiceTalk();
                }
                //开启对讲
                talkPlayer.startVoiceTalk();
                break;
            ///停止对讲
            case "stop_voice_talk":
               boolean isSuccess = true;
                if(talkPlayer != null){
                    isSuccess = talkPlayer.stopVoiceTalk();
                    LogUtils.d("停止对讲"+(isSuccess?"成功":"失败"));
                    talkPlayer.release();
                    talkPlayer = null;
                }
                result.success(isSuccess);
                break;
            /// 获取存储介质状态(如是否初始化，格式化进度等) 该接口为耗时操作，必须在线程中调用
            case "get_storage_status":
                deviceSerial = call.argument("deviceSerial");
                new Thread() {
                    @Override
                    public void run() {
                        Looper.prepare();
                        try {
                           List<EZStorageStatus> statusList = EZOpenSDK.getInstance().getStorageStatus(deviceSerial);
                           result.success(new Gson().toJson(statusList));
                        } catch (BaseException e) {
                            e.printStackTrace();
                            LogUtils.d(e.toString());
                            result.success(null);
                        }
                        Looper.loop();
                    }
                }.start();
                break;

            ///格式化分区
            case "format_storage":
                deviceSerial = call.argument("deviceSerial");
                partitionIndex = call.argument("partitionIndex");
                if(partitionIndex==null) partitionIndex = -1;

                new Thread() {
                    @Override
                    public void run() {
                        Looper.prepare();
                        try {
                           boolean formatResult = EZOpenSDK.getInstance().formatStorage(deviceSerial,partitionIndex);
                           result.success(formatResult);
                        } catch (BaseException e) {
                            e.printStackTrace();
                            result.success(false);
                        }
                        Looper.loop();
                    }
                }.start();
                break;
            /// 释放资源
            case "dispose":
                if(ezPlayer!=null){
                    ezPlayer.setSurfaceHold(null);
                    ezPlayer.release();
                }
                if(talkPlayer != null){
                    talkPlayer.release();
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * 注册播放器
     * @param deviceSerial :序列号，一般通过扫描设备二维码获取，必传。
     * @param verifyCode :视频加密密码，默认为设备的6位验证码，可选。
     * @param cameraNo :通道号,默认为1，可选。
     * @return : 播放组件
     */
    private EZPlayer initEzPlayer(String deviceSerial,String verifyCode,Integer cameraNo){
        int cNo = 1;
        if(cameraNo != null) cNo = cameraNo;

        EZPlayer player = EZOpenSDK.getInstance().createPlayer(deviceSerial, cNo);
        // 设置Handler, 该handler将被用于从播放器向handler传递消息
        player.setHandler(new YsPlayViewHandler(ysResultListener));
        // 设置播放器的显示Surface
        player.setSurfaceEx(textureView.getSurfaceTexture());

        if(verifyCode != null){
            player.setPlayVerifyCode(verifyCode);
        }
        LogUtils.d("播放器初始化成功");
        return player;
    }

    /**
     * 播放器状态监听回调
     */
    YsResultListener ysResultListener = new YsResultListener() {
        @Override
        public void onPlaySuccess() {
            LogUtils.d("onPlaySuccess");
            YsPlayerStatusEntity entity = new YsPlayerStatusEntity();
            entity.setIsSuccess(true);
            ysResult.send(new Gson().toJson(entity));
        }

        @Override
        public void onTalkSuccess() {
            if(talkPlayer!=null) {
                //半双工
                if(supportTalk != null && supportTalk == 3){
                    //isPhone2Dev:
                    //0-手机端听，设备端说.打开扬声器
                    //1-手机端说，设备端听.关闭扬声器
                    talkPlayer.setVoiceTalkStatus(isPhone2Dev==1);
                    talkPlayer.setSpeakerphoneOn(isPhone2Dev==0);
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
     * smartConfig配网回调
     */
    EZOpenSDKListener.EZStartConfigWifiCallback mEZStartConfigWifiCallback =
            new EZOpenSDKListener.EZStartConfigWifiCallback() {
                @Override
                public void onStartConfigWifiCallback(String deviceSerial, EZConstants.EZWifiConfigStatus status) {
                    new Thread(){
                        public void run(){
                            new Handler(Looper.getMainLooper()).post(() -> {
                                PeiwangResultEntity entity = new PeiwangResultEntity();
                                if (status == EZConstants.EZWifiConfigStatus.DEVICE_WIFI_CONNECTED) {
                                    //设备wifi连接成功
                                    //停止Wifi配置
                                    LogUtils.d("smart config——设备WiFi连接成功");
                                } else if (status == EZConstants.EZWifiConfigStatus.DEVICE_PLATFORM_REGISTED) {
                                    //停止Wifi配置
                                    //设备注册到平台成功，可以调用添加设备接口添加设备
                                    entity.setIsSuccess(true);
                                    entity.setMsg("设备配网成功");
                                    LogUtils.d("smart config——设备注册成功");
                                    pwResult.send(new Gson().toJson(entity));
                                } else {
                                    //错误回调
                                    if(status.code== EZConfigWifiErrorEnum.CONFIG_TIMEOUT.code){
                                        status.description = "配网超时";
                                    }
                                    entity.setIsSuccess(false);
                                    entity.setMsg(status.description);
                                    pwResult.send(new Gson().toJson(entity));
                                }
                                EZOpenSDK.getInstance().stopConfigWiFi();
                            });
                        }
                    }.start();
                }
            };

    /// AP配网结果回调
    APWifiConfig.APConfigCallback apConfigCallback = new APWifiConfig.APConfigCallback() {
        @Override
        public void onSuccess() {
            new Thread(){
                public void run(){
                    new Handler(Looper.getMainLooper()).post(() -> LogUtils.d("onSuccess"));
                }
            }.start();
        }

        @Override
        public void onInfo(int code, String message) {
            new Thread(){
                public void run(){
                    new Handler(Looper.getMainLooper()).post(() -> {
                        LogUtils.d("code:"+code);
                        if (code == EZConfigWifiInfoEnum.CONNECTED_TO_PLATFORM.code) {
                            PeiwangResultEntity entity = new PeiwangResultEntity();
                            entity.setIsSuccess(true);
                            entity.setMsg("热点配网成功");
                            LogUtils.d("CONNECTED_TO_PLATFORM");
                            pwResult.send(new Gson().toJson(entity));
                            EZOpenSDK.getInstance().stopAPConfigWifiWithSsid();
                        }
                    });
                }
            }.start();
        }

        @Override
        public void OnError(int code) {
            new Thread(){
                public void run(){
                    new Handler(Looper.getMainLooper()).post(() -> {
                        LogUtils.d("配网失败");
                        PeiwangResultEntity entity = new PeiwangResultEntity();
                        entity.setIsSuccess(false);
                        switch (code) {
                            case 15:
                                entity.setMsg("配网超时");
                                break;
                            case 1:
                                entity.setMsg("参数错误");
                                break;
                            case 2:
                                entity.setMsg("设备ap热点密码错误");
                                break;
                            case 3:
                                entity.setMsg("连接ap热点异常");
                                break;
                            case 4:
                                entity.setMsg("搜索WiFi热点错误");
                                break;
                            case 506:
                                entity.setMsg("用户主动取消热点配网");
                                break;
                            default:
                                entity.setMsg("未知错误:"+code);
                                // 更多错误码请见枚举类 EZConfigWifiErrorEnum 相关说明
                                break;
                        }
                        pwResult.send(new Gson().toJson(entity));
                        EZOpenSDK.getInstance().stopAPConfigWifiWithSsid();
                    });
                }
            }.start();
        }
    };

    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
        if (ezPlayer != null) {
            ezPlayer.setSurfaceEx(surface);
        }
    }

    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
        if (ezPlayer != null) {
            ezPlayer.setSurfaceEx(surface);
        }

    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
        if (ezPlayer != null) {
            ezPlayer.setSurfaceEx(null);
        }

        return false;
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surface) {

    }
}
