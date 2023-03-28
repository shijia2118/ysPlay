import 'dart:io';

import 'package:flutter/material.dart';

class LoadingHelper {
  static bool isLoading = false;

  // 用Dialog弹出一个loading
  static void showDialogLoading(BuildContext context,
      {required String text, Color? barrierColor}) async {
    if (isLoading) {
      return;
    }
    Color? color;
    if (Platform.isIOS) {
      color = Colors.white;
    }
    isLoading = true;

    var widget = WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A).withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            width: 100,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator.adaptive(
                  backgroundColor: color,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 13),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: barrierColor,
      builder: (BuildContext context) => widget,
    );
  }

  // 使用showLoading方法调用的话不需要调用该方法
  static void dismiss(BuildContext context) {
    if (isLoading) {
      isLoading = false;
      Navigator.pop(context);
    }
  }
}
