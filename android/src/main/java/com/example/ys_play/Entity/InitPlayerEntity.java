package com.example.ys_play.Entity;

import com.videogo.openapi.EZPlayer;

public class InitPlayerEntity {

    private EZPlayer player;
    private boolean isSuccess;

    public void setPlayer(EZPlayer player) {
        this.player = player;
    }

    public EZPlayer getPlayer() {
        return player;
    }

    public void setSuccess(boolean success) {
        isSuccess = success;
    }

    public boolean isSuccess() {
        return isSuccess;
    }
}
