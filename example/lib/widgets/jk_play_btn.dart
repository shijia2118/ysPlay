import 'package:flutter/material.dart';

class JkPlayBtn extends StatefulWidget {
  final String playIcon;
  final String pauseIcon;
  final double size;
  final EdgeInsets? padding;
  final Function(bool) onTap;
  final bool isPlaying;
  const JkPlayBtn({
    super.key,
    this.playIcon = 'assets/on_play.png',
    this.pauseIcon = 'assets/on_pause.png',
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.size = 25,
    required this.isPlaying,
  });

  @override
  State<JkPlayBtn> createState() => _JkPlayBtnState();
}

class _JkPlayBtnState extends State<JkPlayBtn> {
  late String playIcon;
  late String pauseIcon;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    initParams();
  }

  @override
  void didUpdateWidget(covariant JkPlayBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      initParams();
    }
  }

  @override
  Widget build(BuildContext context) {
    String icon = pauseIcon;
    if (isPlaying) icon = playIcon;
    return GestureDetector(
      onTap: () {
        setState(() {
          isPlaying = !isPlaying;
        });
        widget.onTap(isPlaying);
      },
      child: Container(
        color: Colors.transparent,
        padding: widget.padding,
        child: Image.asset(
          icon,
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }

  /// 初始化参数
  void initParams() {
    playIcon = widget.playIcon;
    pauseIcon = widget.pauseIcon;
    isPlaying = widget.isPlaying;
  }
}
