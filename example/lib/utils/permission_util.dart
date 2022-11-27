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

  ///权限申请:麦克风
  static microPhone(
    BuildContext context, {
    required Function action,
  }) async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isGranted) {
      await action();
    } else {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        await action();
      }
    }
  }

  ///通讯录和麦克风权限
  // static microContact(
  //   BuildContext context, {
  //   required Function action,
  // }) async {
  //   List<Permission> permissions = [
  //     Permission.microphone,
  //     Permission.contacts,
  //   ];

  //   List<Permission> permissionDenis = [];
  //   for (Permission permission in permissions) {
  //     if (!await permission.status.isGranted) {
  //       permissionDenis.add(permission);
  //     }
  //   }
  //   if (permissionDenis.isEmpty) {
  //     action();
  //   } else {
  //     Map<Permission, PermissionStatus> statuses = await permissionDenis.request();
  //     print('>>>>>>>$statuses');
  //     Permission.microphone
  //   }
  // }
}
