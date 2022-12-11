package com.example.ys_play.Interface;

public interface YsResultListener {
    void onPlaySuccess();
    void onTalkSuccess();
    void onPlayError(String errorInfo);
    void onTalkError(String errorInfo);
}
