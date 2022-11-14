import 'package:flutter/material.dart';

class FullScreenBtn extends StatelessWidget {
  final Function() onTap;
  final Orientation orientation;
  const FullScreenBtn({
    super.key,
    required this.onTap,
    this.orientation = Orientation.portrait,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset(
          orientation == Orientation.portrait
              ? 'assets/icon_full_screen.png'
              : 'assets/icon_full_screen2.png',
          width: 25,
          height: 25,
        ),
      ),
    );
  }
}
