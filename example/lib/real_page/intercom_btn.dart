import 'package:flutter/material.dart';

class IntercomBtn extends StatefulWidget {
  final Function(bool) onIntercom;
  const IntercomBtn({
    super.key,
    required this.onIntercom,
  });

  @override
  State<IntercomBtn> createState() => _IntercomBtnState();
}

class _IntercomBtnState extends State<IntercomBtn> {
  bool isTalking = false;

  @override
  Widget build(BuildContext context) {
    String icon = 'assets/icon_intercom.png';
    if (isTalking) icon = 'assets/icon_intercom_true.png';
    return IconButton(
      onPressed: onPressed,
      icon: Image.asset(icon),
    );
  }

  /// 点击事件
  void onPressed() async {
    setState(() {
      isTalking = !isTalking;
    });
    widget.onIntercom(isTalking);
  }
}
