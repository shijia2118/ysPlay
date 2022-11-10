package com.example.ys_play.Entity;

import com.google.gson.annotations.SerializedName;

public class YsPlayerStatusEntity {

    @SerializedName(value="isSuccess")
    private boolean isSuccess;
    private String errorInfo;

    public boolean isIsSuccess() {
        return isSuccess;
    }

    public void setIsSuccess(boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

    public String getErrorInfo() {
        return errorInfo;
    }

    public void setErrorInfo(String errorInfo) {
        this.errorInfo = errorInfo;
    }
}
