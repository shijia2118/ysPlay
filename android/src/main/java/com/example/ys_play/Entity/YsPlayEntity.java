package com.example.ys_play.Entity;

public class YsPlayEntity {
    private String code;
    private String Data;
    private long callBackFuncId;

    public YsPlayEntity(String code, String data) {
        this.code = code;
        Data = data;
    }

    public long getCallBackFuncId() {
        return callBackFuncId;
    }

    public void setCallBackFuncId(long callBackFuncId) {
        this.callBackFuncId = callBackFuncId;
    }
}
