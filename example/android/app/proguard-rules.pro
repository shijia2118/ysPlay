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