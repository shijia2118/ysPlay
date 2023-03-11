import 'package:dio/dio.dart';
import 'package:ys_play/src/entity/capacity_response_entity.dart';
import 'package:ys_play/src/entity/ys_request_entity.dart';

import 'entity/ys_response_entity.dart';

class YsHttpApi {
  /// 开始云台控制
  static const String ptzStart =
      "https://open.ys7.com/api/lapp/device/ptz/start";

  /// 关闭云台控制
  static const String ptzStop = "https://open.ys7.com/api/lapp/device/ptz/stop";

  /// 镜像翻转
  static const String ptzMirror =
      "https://open.ys7.com/api/lapp/device/ptz/mirror";

  /// 设备能力集
  static const String devCapacity =
      "https://open.ys7.com/api/lapp/device/capacity";

  /// 开始云台控制
  static Future<YsResponseEntity> devPtzStart({
    required String accessToken,
    required String deviceSerial,
    required int channelNo,
    required int direction,
    int? speed,
  }) async {
    FormData formData = FormData.fromMap({
      "accessToken": accessToken,
      "deviceSerial": deviceSerial,
      "channelNo": channelNo,
      "direction": direction,
      "speed": speed ?? 1,
    });

    try {
      Response response = await Dio().post(ptzStart, data: formData);
      if (response.statusCode == 200) {
        YsResponseEntity responseData =
            YsResponseEntity.fromJson(response.data);
        return responseData;
      } else {
        // 失败
        return YsResponseEntity.fromJson({
          "code": response.statusCode,
          "msg": response.statusMessage,
        });
      }
    } catch (e) {
      throw ("请求错误:${e.toString()}");
    }
  }

  /// 停止云台控制
  static Future<YsResponseEntity> devPtzStop({
    required String accessToken,
    required String deviceSerial,
    required int channelNo,
    int? direction,
  }) async {
    FormData formData = FormData.fromMap({
      "accessToken": accessToken,
      "deviceSerial": deviceSerial,
      "channelNo": channelNo,
      "direction": direction,
    });
    try {
      Response response = await Dio().post(ptzStop, data: formData);
      if (response.statusCode == 200) {
        YsResponseEntity responseData =
            YsResponseEntity.fromJson(response.data);
        return responseData;
      } else {
        // 失败
        return YsResponseEntity.fromJson({
          "code": response.statusCode,
          "msg": response.statusMessage,
        });
      }
    } catch (e) {
      throw ("请求错误:${e.toString()}");
    }
  }

  /// 镜像翻转
  static Future<YsResponseEntity> devPtzMirror(
      YsRequestEntity requestEntity) async {
    FormData formData = FormData.fromMap({
      "accessToken": requestEntity.accessToken,
      "deviceSerial": requestEntity.deviceSerial,
      "channelNo": requestEntity.channelNo,
      "command": requestEntity.command,
    });

    try {
      Response response = await Dio().post(ptzMirror, data: formData);
      if (response.statusCode == 200) {
        YsResponseEntity responseData =
            YsResponseEntity.fromJson(response.data);
        return responseData;
      } else {
        // 失败
        return YsResponseEntity.fromJson({
          "code": response.statusCode,
          "msg": response.statusMessage,
        });
      }
    } catch (e) {
      throw ("请求错误:${e.toString()}");
    }
  }

  /// 设备能力集
  static Future<CapacityResponseEntity> getDevCapacity({
    required String accessToken,
    required String deviceSerial,
  }) async {
    FormData formData = FormData.fromMap({
      "accessToken": accessToken,
      "deviceSerial": deviceSerial,
    });

    try {
      Response response = await Dio().post(devCapacity, data: formData);
      if (response.statusCode == 200) {
        CapacityResponseEntity responseData =
            CapacityResponseEntity.fromJson(response.data);
        return responseData;
      } else {
        // 失败
        return CapacityResponseEntity.fromJson({
          "code": response.statusCode,
          "msg": response.statusMessage,
        });
      }
    } catch (e) {
      throw ("请求错误:${e.toString()}");
    }
  }
}
