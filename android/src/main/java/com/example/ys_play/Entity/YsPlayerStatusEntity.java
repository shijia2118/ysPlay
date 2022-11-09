package com.example.ys_play.Entity;

public class YsPlayerStatusEntity {

    String errorInfo;
    boolean isSuccess;

    public String getErrorInfo(){
        return errorInfo;
    }

    public void setErrorInfo(String errorInfo){
        this.errorInfo = errorInfo;
    }

    public boolean getSuccess(){
        return isSuccess;
    }

    public void setSuccess(boolean isSuccess){
        this.isSuccess = isSuccess;
    }
}
