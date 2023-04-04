import 'package:flutter/material.dart';
import 'package:ys_play/ys_play.dart';

class JkPlayBtn extends StatefulWidget {
  final String playIcon;
  final String pauseIcon;
  final double size;
  final EdgeInsets? padding;
  final Function(YsPlayStatus) onTap;
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
  late YsMediaType mediaType;

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
    String icon = pauseIcon;
    if (ysPlayStatus == YsPlayStatus.onPlaying) {
      icon = playIcon;
    }
    return GestureDetector(
      onTap: () {
        if (ysPlayStatus == YsPlayStatus.onPrepareing) {
          return;
        } else if (ysPlayStatus == YsPlayStatus.onPlaying) {
          ysPlayStatus = YsPlayStatus.onStop;
        } else if (ysPlayStatus == YsPlayStatus.onError) {
          ysPlayStatus = YsPlayStatus.onPrepareing;
        } else if (ysPlayStatus == YsPlayStatus.onStop) {
          ysPlayStatus = YsPlayStatus.onPlaying;
        }
        widget.onTap(ysPlayStatus);
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
