import 'package:flutter/material.dart';
import 'package:ys_play/ys_play.dart';

import '../widgets/bottom_handle_bar.dart';
import '../widgets/player_forground_widget.dart';

class YsPlayerPortrait extends StatelessWidget {
  final double width;
  final double height;
  final Function(YsPlayStatus) onPlayHandle;
  final Function()? onFullScreenHandle;
  final Function(bool) onSoundHandle;
  final Function() onScreenTouched;
  final YsPlayStatus ysPlayStatus;
  final Function(int) onSelectLevelHandle;
  final YsMediaType mediaType;
  final Function()? onRePlay;
  final String? errorInfo;
  const YsPlayerPortrait({
    super.key,
    required this.width,
    required this.height,
    required this.onFullScreenHandle,
    required this.onPlayHandle,
    required this.onSoundHandle,
    required this.onScreenTouched,
    required this.onSelectLevelHandle,
    this.mediaType = YsMediaType.playback,
    required this.onRePlay,
    required this.ysPlayStatus,
    this.errorInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //底层播放视图
        const YsPlayView(),
        GestureDetector(
          onTap: onScreenTouched,
          child: Container(
            height: height,
            width: width,
            color: Colors.transparent,
          ),
        ),
        //底部操作按钮组
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomHandleBar(
            width: width,
            height: 35,
            ysPlayStatus: ysPlayStatus,
            onPlayHandle: (status) => onPlayHandle(status),
            onFullScreenHandle: onFullScreenHandle,
            onSoundHandle: (isOpen) => onSoundHandle(isOpen),
            onSelectLevelHandle: (i) => onSelectLevelHandle(i),
            mediaType: mediaType,
          ),
        ),
        //视图上层加载指示器
        PlayerForgroundWidget(
          errorInfo: errorInfo,
          isVisible: ysPlayStatus == YsPlayStatus.onPrepareing,
          onRePlay: onRePlay,
        ),
      ],
    );
  }
}
