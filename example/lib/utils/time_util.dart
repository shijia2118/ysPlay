import 'package:intl/intl.dart';

class TimeUtil {
  static DateTime now = DateTime.now();

  /// 时间戳转字符串日期
  static String timeFormat(int? timestamp, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return timestamp == null
        ? ''
        : DateFormat(format).format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  /// 字符串日期转时间戳
  static int String2timeStamp(String time) {
    DateTime dt = DateTime.parse(time);
    return dt.millisecondsSinceEpoch;
  }

  //数字格式化，将 0~9 的时间转换为 00~09
  static String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  /// 转为当前日期的0时
  static String date2Zero(DateTime dt) {
    String t = DateFormat('yyyy-MM-dd').format(dt);
    return t + ' ' + '00:00:00';
  }
}
