import 'package:flutter/material.dart';
import 'package:ys_play_example/ys_player/ys_player.dart';

class JkPlayBtn extends StatefulWidget {
  final String playIcon;
  final String pauseIcon;
  final double size;
  final EdgeInsets? padding;
  final Function(bool) onTap;
  final YsPlayStatus ysPlayStatus;
  const JkPlayBtn({
    super.key,
    this.playIcon = 'assets/on_play.png',
    this.pauseIcon = 'assets/on_pause.png',
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.size = 25,
    required this.ysPlayStatus,
  });

  @override
  State<JkPlayBtn> createState() => _JkPlayBtnState();
}

class _JkPlayBtnState extends State<JkPlayBtn> {
  late String playIcon;
  late String pauseIcon;
  late YsPlayStatus ysPlayStatus;

  @override
  void initState() {
    super.initState();
    initParams();
  }

  @override
  void didUpdateWidget(covariant JkPlayBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    initParams();
  }

  @override
  Widget build(BuildContext context) {
    String icon = playIcon;
    if (ysPlayStatus == YsPlayStatus.onInitial) {
      icon = pauseIcon;
    }
    return GestureDetector(
      onTap: () {
        if (ysPlayStatus == YsPlayStatus.onInitial || ysPlayStatus == YsPlayStatus.onPause) {
          ysPlayStatus == YsPlayStatus.onPlaying;
        } else if
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
    ysPlayStatus = widget.ysPlayStatus;
  }
}
