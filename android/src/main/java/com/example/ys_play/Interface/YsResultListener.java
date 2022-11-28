package com.example.ys_play.Interface;

public interface YsResultListener {
    void onRealPlaySuccess();
    void onPlayBackSuccess();
    void onTalkBackSuccess();
    void onError(String errorInfo);
}
