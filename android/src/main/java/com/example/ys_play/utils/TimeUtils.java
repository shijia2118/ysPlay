package com.example.ys_play.utils;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

public class TimeUtils {
    public static String dateFormat_day = "HH:mm";
    public static String dateFormat_month = "MM-dd";

    /**
     * 时间转换成字符串,默认为"yyyy-MM-dd HH:mm:ss"
     *
     * @param time 时间
     */
    public static String dateToString(long time) {
        return dateToString(time, "yyyy-MM-dd HH:mm:ss");
    }

    /**
     * 时间转换成字符串,指定格式
     *
     * @param time   时间
     * @param format 时间格式
     */
    public static String dateToString(long time, String format) {
        Date date = new Date(time);
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(format);
        return simpleDateFormat.format(date);
    }

    public static Date parseServerTime(String serverTime, String format) {
        if (format == null || format.isEmpty()) {
            format = "yyyy-MM-dd HH:mm:ss";
        }
        SimpleDateFormat sdf = new SimpleDateFormat(format, Locale.CHINESE);
        sdf.setTimeZone(TimeZone.getTimeZone("GMT+8:00"));
        Date date = null;
        try {
            date = sdf.parse(serverTime);
        } catch (Exception e) {
        }
        return date;
    }



    /**
     * 获取当前的时间戳
     *
     * @return
     */
    public static long getTimeStame() {
        //获取当前的毫秒值
        long time = System.currentTimeMillis();
        //将毫秒值转换为String类型数据
        long time_stamp = time;
        //返回出去
        return time_stamp;
    }
}
