# ysPlay

Flutter萤石云直播插件，支持Android和IOS

## 支持
1.账号对接（授权登录）  
2.直播(可设置直播分辨率)  
3.回放  
4.直播、回放边播边录  
5.直播、回放边播边截屏  
6.云台控制  
7.配网  
8.对讲(包含半双工对讲和全双工对讲)  

## 准备工作
集成之前，最好读一下[官方文档](http://open.ys7.com/help/36).

## 安装
    dependencies: 
        ys_play: ^0.1.0

## 工程配置
### Android端
在 AndroidMainfest.xml 文件中添加：
```       
<!-- 基础功能所需权限 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<!-- 配网所需权限 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
<!-- 读取权限 选择本地相册-->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<!-- 存入权限 需要把拍摄的照片或视频存入-->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<!-- 网络定位 -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<!-- 麦克风权限-->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
```       

在项目app目录下添加:

    defaultConfig {
       ...
        ndk {
            abiFilters "armeabi-v7a", "arm64-v8a"
        }
    }

     sourceSets {
        main {
            jniLibs.srcDirs = ['libs']
        }
    }

代码混淆:

    #========SDK对外接口=======#
    -keep class com.ezviz.opensdk.** { *;}

    #========以下是hik二方库=======#
    -dontwarn com.ezviz.**
    -keep class com.ezviz.** { *;}

    -dontwarn com.ez.**
    -keep class com.ez.** { *;}

    -dontwarn com.hc.CASClient.**
    -keep class com.hc.CASClient.** { *;}

    -dontwarn com.videogo.**
    -keep class com.videogo.** { *;}

    -dontwarn com.hik.TTSClient.**
    -keep class com.hik.TTSClient.** { *;}

    -dontwarn com.hik.stunclient.**
    -keep class com.hik.stunclient.** { *;}

    -dontwarn com.hik.streamclient.**
    -keep class com.hik.streamclient.** { *;}

    -dontwarn com.hikvision.sadp.**
    -keep class com.hikvision.sadp.** { *;}

    -dontwarn com.hikvision.netsdk.**
    -keep class com.hikvision.netsdk.** { *;}

    -dontwarn com.neutral.netsdk.**
    -keep class com.neutral.netsdk.** { *;}

    -dontwarn com.hikvision.audio.**
    -keep class com.hikvision.audio.** { *;}

    -dontwarn com.mediaplayer.audio.**
    -keep class com.mediaplayer.audio.** { *;}

    -dontwarn com.hikvision.wifi.**
    -keep class com.hikvision.wifi.** { *;}

    -dontwarn com.hikvision.keyprotect.**
    -keep class com.hikvision.keyprotect.** { *;}

    -dontwarn com.hikvision.audio.**
    -keep class com.hikvision.audio.** { *;}

    -dontwarn org.MediaPlayer.PlayM4.**
    -keep class org.MediaPlayer.PlayM4.** { *;}
    #========以上是hik二方库=======#

    #========以下是第三方开源库=======#
    # JNA
    -dontwarn com.sun.jna.**
    -keep class com.sun.jna.** { *;}

    # Gson
    -keepattributes *Annotation*
    -keep class sun.misc.Unsafe { *; }
    -keep class com.idea.fifaalarmclock.entity.***
    -keep class com.google.gson.stream.** { *; }

    # OkHttp
    # JSR 305 annotations are for embedding nullability information.
    -dontwarn javax.annotation.**
    # A resource is loaded with a relative path so the package of this class must be preserved.
    -keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
    # Animal Sniffer compileOnly dependency to ensure APIs are compatible with older versions of Java.
    -dontwarn org.codehaus.mojo.animal_sniffer.*
    # OkHttp platform used only on JVM and when Conscrypt dependency is available.
    -dontwarn okhttp3.internal.platform.ConscryptPlatform
    # 必须额外加的，否则编译无法通过
    -dontwarn okio.**
    #========以上是第三方开源库=======#


### IOS端
## 在info.plist中添加:  

1.相册权限： 如果需要使用开放平台播放器录像和截图并保存的功能，就需要配置相册权限。   
```              
<key>NSPhotoLibraryAddUsageDescription</key>  
<string>$(PRODUCT_NAME)需要使用手机相册</string>  
<key>NSPhotoLibraryUsageDescription</key>  
<string>$(PRODUCT_NAME)需要使用手机相册</string>  
```

2.麦克风权限： 如果需要使用设备对讲功能，就需要配置麦克风权限。务必在发起对讲前向iOS系统申请麦克风权限，否则将导致对讲异常。        
```
<key>NSMicrophoneUsageDescription</key>    
<string>$(PRODUCT_NAME)需要使用手机麦克风</string>
```

3.摄像头权限： 如果需要仿照demo实现扫码添加设备功能，就需要配置摄像头权限。 
```
<key>NSCameraUsageDescription</key>    
<string>$(PRODUCT_NAME)需要使用手机照相机</string>
```

4.配网权限: 如果需要使用萤石云设备入网配置，就需要配置配网权限  
 ```       
<key>NSLocalNetworkUsageDescription</key>  
<string>$(PRODUCT_NAME)需要使用本地网络权限用于wifi配网</string>  
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>  
<string>$(PRODUCT_NAME)需要使用定位权限用于wifi配网</string>  
<key>NSLocationAlwaysUsageDescription</key>
<string>$(PRODUCT_NAME)需要使用定位权限用于wifi配网</string>  
<key>NSLocationWhenInUseUsageDescription</key>  
<string>$(PRODUCT_NAME)需要使用定位权限用于wifi配网</string>  
```

## 在xcode中配置
在xcode -> Runner -> Target -> Target-Signing & Capabilities中，添加以下2项能力:
1.Access WiFi Information(获取手机连接的WiFi名，配网需要);
2.Hotspot Configuation(连接指定WiFi，配网需要).
注意：上述2项能力，同时需要在appstore官网证书上添加相关能力。

## 使用方式
具体请见example中的功能，里面有详细注释。

   
	

	




