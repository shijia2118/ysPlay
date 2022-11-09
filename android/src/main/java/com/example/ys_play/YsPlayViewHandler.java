package com.example.ys_play;

import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

import com.example.ys_play.Interface.PlayerStatusListener;
import com.videogo.errorlayer.ErrorInfo;
import com.videogo.openapi.EZConstants;

import io.flutter.Log;

class YsPlayViewHandler extends Handler {
    private final PlayerStatusListener playerStatusListener;

    public YsPlayViewHandler(PlayerStatusListener playerStatusListener){
        this.playerStatusListener = playerStatusListener;
    }

    @Override
    public void handleMessage(@NonNull Message msg) {
        final String TAG = "萤石LOG======>";
        switch (msg.what) {
            case EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_PLAY_SUCCUSS:
                Log.d(TAG,"回放播放成功");
                playerStatusListener.onSuccess();
                break;
            case EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_PLAY_FAIL:
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_FAIL:
                //播放失败,得到失败信息
                ErrorInfo errorinfo = (ErrorInfo) msg.obj;
                //得到播放失败描述
                String description = errorinfo.description;
                //错误信息回调
                playerStatusListener.onError(description);
                break;
            case EZConstants.MSG_VIDEO_SIZE_CHANGED:
                //解析出视频画面分辨率回调
                try {
                    String temp = (String) msg.obj;
                    String[] strings = temp.split(":");
                    int mVideoWidth = Integer.parseInt(strings[0]);
                    int mVideoHeight = Integer.parseInt(strings[1]);
                    Log.i(TAG,"width:"+mVideoWidth+";"+"height:"+mVideoHeight);
                    //解析出视频分辨率
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_SUCCESS:
                Log.d(TAG,"直播播放成功");
                playerStatusListener.onSuccess();
                break;

            default:
                break;
        }
    }


}
