import 'package:flutter/material.dart';

class JkSoundBtn extends StatefulWidget {
  final Function(bool) onTap;
  final String openIcon;
  final String closeIcon;
  final EdgeInsets? padding;
  final double size;
  const JkSoundBtn({
    super.key,
    required this.onTap,
    this.openIcon = 'assets/icon_sound_open.png',
    this.closeIcon = 'assets/icon_sound_close.png',
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.size = 25,
  });

  @override
  State<JkSoundBtn> createState() => _JkSoundBtnState();
}

class _JkSoundBtnState extends State<JkSoundBtn> {
  bool isOpen = false;
  late String openIcon;
  late String closeIcon;
  EdgeInsets? padding;
  late double size;

  @override
  void initState() {
    super.initState();
    initParams();
  }

  @override
  Widget build(BuildContext context) {
    String icon = isOpen ? openIcon : closeIcon;

    return GestureDetector(
      onTap: onSoundBtnClicked,
      child: Container(
        alignment: Alignment.center,
        padding: padding,
        color: Colors.transparent,
        child: Image.asset(
          icon,
          width: size,
          height: size,
        ),
      ),
    );
  }

  ///初始化参数
  void initParams() {
    openIcon = widget.openIcon;
    closeIcon = widget.closeIcon;
    padding = widget.padding;
    size = widget.size;
  }

  /// 按钮点击事件
  void onSoundBtnClicked() {
    setState(() {
      isOpen = !isOpen;
    });
    widget.onTap(isOpen);
  }
}
