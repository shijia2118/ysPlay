package com.example.ys_play;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import androidx.annotation.NonNull;

import com.example.ys_play.Entity.PlayerStatusEntity;
import com.google.gson.Gson;
import com.videogo.errorlayer.ErrorInfo;
import com.videogo.openapi.EZConstants;

import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;

class YsPlayViewHandler extends Handler {
    BasicMessageChannel<Object> playerStatus;
    PlayerStatusEntity playerStatusEntity = new PlayerStatusEntity();


    YsPlayViewHandler(Looper looper, @NonNull BinaryMessenger messenger){
        super(looper);
        playerStatus = new BasicMessageChannel<>(messenger, Constants.PLAYER_STATUS_CHANNEL, new StandardMessageCodec());
    }

    @Override
    public void handleMessage(@NonNull Message msg) {
        final String TAG = "萤石LOG======>";
        Log.d(TAG,">>>回放播放成功");

        switch (msg.what) {

            case EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_PLAY_SUCCUSS:
                Log.d(TAG,"回放播放成功");
                playerStatusEntity.setStatus(msg.what);
                //向Flutter端发送消息
                playerStatus.send(new Gson().toJson(playerStatusEntity));
                break;
            case EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_PLAY_FAIL:
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
                playerStatusEntity.setStatus(msg.what);
                playerStatusEntity.setErrorInfo(errorinfo);
                //向Flutter端发送消息
                playerStatus.send(new Gson().toJson(playerStatusEntity));
                break;
            case EZConstants.MSG_VIDEO_SIZE_CHANGED:
                //解析出视频画面分辨率回调
                try {
                    String temp = (String) msg.obj;
                    String[] strings = temp.split(":");
//                    int mVideoWidth = Integer.parseInt(strings[0]);
//                    int mVideoHeight = Integer.parseInt(strings[1]);
//                    Log.i(TAG,"width:"+mVideoWidth+";"+"height:"+mVideoHeight);
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
