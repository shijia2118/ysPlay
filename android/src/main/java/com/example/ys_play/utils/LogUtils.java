package com.example.ys_play.utils;

import android.util.Log;

import io.flutter.BuildConfig;

public class LogUtils {
    static String TAG =  "萤石LOG========>";

    public static void d(String text){
        if(BuildConfig.DEBUG && text!=null){
            Log.d(TAG,text);
        }
    }
}
