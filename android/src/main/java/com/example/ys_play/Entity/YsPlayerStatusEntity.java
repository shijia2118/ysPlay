package com.example.ys_play.Entity;

import com.google.gson.annotations.SerializedName;

public class YsPlayerStatusEntity {

    @SerializedName(value="isSuccess")
    private boolean isSuccess;
    private String playErrorInfo;
    private String talkErrorInfo;

    public boolean isIsSuccess() {
        return isSuccess;
    }

    public void setIsSuccess(boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

    public String getPlayErrorInfo() {
        return playErrorInfo;
    }

    public void setPlayErrorInfo(String playErrorInfo) {
        this.playErrorInfo = playErrorInfo;
    }

    public String getTalkErrorInfo() {
        return talkErrorInfo;
    }

    public void setTalkErrorInfo(String talkErrorInfo) {
        this.talkErrorInfo = talkErrorInfo;
    }
}
