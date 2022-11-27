package com.example.ys_play;

import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

import com.example.ys_play.Interface.PlayerStatusListener;
import com.videogo.errorlayer.ErrorInfo;
import com.videogo.exception.ErrorCode;
import com.videogo.openapi.EZConstants;

import io.flutter.Log;

class YsPlayViewHandler extends Handler {
    private final PlayerStatusListener playerStatusListener;
    private ErrorInfo errorinfo=null;

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
                 errorinfo = (ErrorInfo) msg.obj;
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
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_VOICETALK_FAIL:
                //得到播放失败描述
                errorinfo = (ErrorInfo) msg.obj;
                handleVoiceTalkFailed(errorinfo);
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_VOICETALK_SUCCESS:
                Log.d(TAG,"对讲成功");
                playerStatusListener.onSuccess();
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_VOICETALK_STOP:
                Log.d(TAG,"停止对讲");
                break;
            default:
                break;
        }
    }

    /**
     * 对讲失败
     * @param errorInfo
     */
    private void handleVoiceTalkFailed(ErrorInfo errorInfo) {
        String errorDes = "";
        switch (errorInfo.errorCode) {
            case ErrorCode.ERROR_TRANSF_DEVICE_TALKING:
                errorDes = "同一时间只能与一台设备进行对讲哦，请停止其他对讲后再尝试";
                break;
            case ErrorCode.ERROR_TRANSF_DEVICE_PRIVACYON:
                errorDes = "隐私保护模式下无法对讲";
                break;
            case ErrorCode.ERROR_TRANSF_DEVICE_OFFLINE:
                errorDes = "设备不在线";
                break;
            case ErrorCode.ERROR_TTS_MSG_REQ_TIMEOUT:
            case ErrorCode.ERROR_TTS_MSG_SVR_HANDLE_TIMEOUT:
            case ErrorCode.ERROR_TTS_WAIT_TIMEOUT:
            case ErrorCode.ERROR_TTS_HNADLE_TIMEOUT:
                errorDes="请求超时，对讲已关闭";
                break;
            case ErrorCode.ERROR_CAS_AUDIO_SOCKET_ERROR:
            case ErrorCode.ERROR_CAS_AUDIO_RECV_ERROR:
            case ErrorCode.ERROR_CAS_AUDIO_SEND_ERROR:
                errorDes="网络异常，对讲已关闭";
                break;
            case ErrorCode.ERROR_INNER_STREAM_TIMEOUT:
                errorDes="取流超时，刷新重试";
                break;
            case 110031://子账户或萤石用户没有权限
                break;
            default:
                errorDes = "" + errorInfo.errorCode;
                break;
        }
        playerStatusListener.onError(errorDes);
    }



}
