package com.example.ys_play;

import com.videogo.openapi.EZPlayer;

public interface OnSurfaceViewCreated {
    void createPlayer(EZPlayer ezPlayer);
    void result(boolean isSuccess);
}
