package com.example.ys_play;

import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

import com.videogo.errorlayer.ErrorInfo;
import com.videogo.openapi.EZConstants;

import io.flutter.Log;

class YsPlayViewHandler extends Handler {
    @Override
    public void handleMessage(@NonNull Message msg) {
        Log.d(">>>>>>>>",""+msg);

        switch (msg.what) {
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_SUCCESS:
                Log.d("ys7","播放成功");
                //播放成功
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_FAIL:
                //播放失败,得到失败信息
                ErrorInfo errorinfo = (ErrorInfo) msg.obj;
                //得到播放失败错误码
                int code = errorinfo.errorCode;
                //得到播放失败模块错误码
                String codeStr = errorinfo.moduleCode;
                //得到播放失败描述
                String description = errorinfo.description;
                //得到播放失败解决方方案
                String sulution = errorinfo.sulution;
                break;
            case EZConstants.MSG_VIDEO_SIZE_CHANGED:
                //解析出视频画面分辨率回调
                try {
                    String temp = (String) msg.obj;
                    String[] strings = temp.split(":");
                    int mVideoWidth = Integer.parseInt(strings[0]);
                    int mVideoHeight = Integer.parseInt(strings[1]);
                    //解析出视频分辨率
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            default:
                break;
        }
    }
}
