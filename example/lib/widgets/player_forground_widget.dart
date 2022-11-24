import 'package:flutter/material.dart';

class PlayerForgroundWidget extends StatelessWidget {
  final bool isVisible;
  final String? errorInfo;
  final Function()? onRePlay;
  const PlayerForgroundWidget({
    Key? key,
    this.isVisible = true,
    this.errorInfo,
    this.onRePlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorInfo != null) {
      return GestureDetector(
        onTap: onRePlay,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/re_play.png',
                width: 25,
                height: 25,
              ),
              SizedBox(height: 8),
              Text(
                errorInfo!,
                style: TextStyle(color: Colors.white, fontSize: 12),
                softWrap: true,
                maxLines: 2,
              ),
            ],
          ),
        ),
      );
    }
    return Visibility(
      visible: isVisible,
      child: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
