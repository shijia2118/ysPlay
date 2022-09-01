package com.example.ys_play.Entity;

import com.videogo.errorlayer.ErrorInfo;

public class PlayerStatusEntity {
    private boolean isSuccess;
    private String description;

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    public void setSuccess(boolean success) {
        isSuccess = success;
    }

    public boolean isSuccess() {
        return isSuccess;
    }
}
