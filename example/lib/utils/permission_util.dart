import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  ///存储权限
  static storage(BuildContext context, {required Function action}) async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) {
      await action();
    } else {
      status = await Permission.storage.request();
      if (status.isGranted) {
        await action();
      }
    }
  }

  ///权限申请:定位
  static location(
    BuildContext context, {
    required Function action,
  }) async {
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted) {
      await action();
    } else {
      status = await Permission.location.request();
      if (status.isGranted) {
        await action();
      }
    }
  }
}
