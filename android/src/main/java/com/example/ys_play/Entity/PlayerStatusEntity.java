package com.example.ys_play.Entity;

public class PlayerStatusEntity {
    private boolean isSuccess;
    private String description;

    public void setSuccess(boolean success) {
        isSuccess = success;
    }

    public boolean isSuccess() {
        return isSuccess;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
