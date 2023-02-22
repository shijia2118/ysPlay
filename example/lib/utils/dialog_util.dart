import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogUtil {
  static showCommonDialog(
    BuildContext context,
    String title, {
    required Widget content,
    bool noCancel = false,
    String confirm = '确定',
    String cancel = '取消',
    Function()? onTap,
  }) async {
    if (Platform.isIOS) {
      List<Widget> actions = [];
      if (!noCancel) {
        actions.add(CupertinoDialogAction(
          child: Text(
            cancel,
            style: TextStyle(
              fontSize: 17,
              color: Colors.blueGrey,
            ),
          ),
          onPressed: () => Navigator.pop(context, false),
        ));
      }
      actions.add(
        CupertinoDialogAction(
          child: Text(
            confirm,
            style: TextStyle(
              fontSize: 17,
              color: Colors.blue,
            ),
          ),
          onPressed: onTap,
        ),
      );
      return await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: content,
          actions: actions,
        ),
      );
    } else {
      List<Widget> actions = [];
      if (!noCancel) {
        actions.add(TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel)));
      }
      actions.add(
        TextButton(
          child: Text(
            confirm,
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: onTap,
        ),
      );
      return await showDialog(
        context: context,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            contentPadding: EdgeInsets.zero,
            title: Text(
              title,
            ),
            content: content,
            actions: actions,
          ),
        ),
      );
    }
  }
}
