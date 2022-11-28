package com.example.ys_play;

import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

import com.example.ys_play.Interface.YsResultListener;
import com.example.ys_play.utils.LogUtils;
import com.videogo.errorlayer.ErrorInfo;
import com.videogo.exception.ErrorCode;
import com.videogo.openapi.EZConstants;

class YsPlayViewHandler extends Handler {
    private final YsResultListener ysResult;

    public YsPlayViewHandler(YsResultListener ysResult){
        this.ysResult = ysResult;
    }

    @Override
    public void handleMessage(@NonNull Message msg) {
        ErrorInfo errorinfo = (ErrorInfo) msg.obj;
        switch (msg.what) {
            case EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_PLAY_SUCCUSS:
                LogUtils.d("回放播放成功");
                ysResult.onPlayBackSuccess();
                break;
            case EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_PLAY_FAIL:
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_FAIL:
                //得到播放失败描述
                String description = errorinfo.description;
                //错误信息回调
                ysResult.onError(description);
                break;
            case EZConstants.MSG_VIDEO_SIZE_CHANGED:
                //解析出视频画面分辨率回调
                try {
                    String temp = (String) msg.obj;
                    //解析出视频分辨率
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_SUCCESS:
                LogUtils.d("直播播放成功");
                ysResult.onRealPlaySuccess();
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_VOICETALK_FAIL:
                handleVoiceTalkFailed(errorinfo);
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_VOICETALK_SUCCESS:
                LogUtils.d("对讲成功");
                ysResult.onTalkBackSuccess();
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_VOICETALK_STOP:
                LogUtils.d("停止对讲");
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
        ysResult.onError(errorDes);
    }



}
