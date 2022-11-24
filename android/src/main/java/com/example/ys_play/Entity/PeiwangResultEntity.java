package com.example.ys_play.Entity;

import com.google.gson.annotations.SerializedName;

public class PeiwangResultEntity {

    @SerializedName(value="isSuccess")
    private boolean isSuccess;

    @SerializedName(value="msg")
    private String msg;

    public boolean isIsSuccess() {
        return isSuccess;
    }

    public void setIsSuccess(boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }
}
