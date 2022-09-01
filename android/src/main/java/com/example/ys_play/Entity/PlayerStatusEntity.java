package com.example.ys_play.Entity;

import com.videogo.errorlayer.ErrorInfo;

public class PlayerStatusEntity {
    private int status;
    private ErrorInfo errorInfo;

    public void setErrorInfo(ErrorInfo errorInfo) {
        this.errorInfo = errorInfo;
    }

    public ErrorInfo getErrorInfo() {
        return errorInfo;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getStatus() {
        return status;
    }
}
