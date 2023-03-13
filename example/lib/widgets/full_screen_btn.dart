import 'package:flutter/material.dart';

class FullScreenBtn extends StatelessWidget {
  final Function() onTap;
  final bool isFullScreen;
  const FullScreenBtn(
      {super.key, required this.onTap, this.isFullScreen = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset(
          isFullScreen
              ? 'assets/icon_full_screen2.png'
              : 'assets/icon_full_screen.png',
          width: 25,
          height: 25,
        ),
      ),
    );
  }
}
