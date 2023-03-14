import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ys_play_example/widgets/full_screen_btn.dart';
import 'package:ys_play_example/widgets/jk_level_btn.dart';
import 'package:ys_play_example/widgets/jk_sound_btn.dart';

import '../ys_player/ys_player.dart';
import 'jk_play_btn.dart';

class BottomHandleBar extends StatefulWidget {
  final double? width;
  final double? height;
  final Function(YsPlayStatus)? onPlayHandle;
  final Function(bool)? onSoundHandle;
  final Function()? onFullScreenHandle;
  final Function(int)? onSelectLevelHandle;
  final YsPlayStatus ysPlayStatus;
  final YsMediaType mediaType;
  const BottomHandleBar({
    Key? key,
    this.height,
    this.width,
    this.onFullScreenHandle,
    this.onPlayHandle,
    this.onSoundHandle,
    this.onSelectLevelHandle,
    required this.ysPlayStatus,
    required this.mediaType,
  }) : super(key: key);

  @override
  State<BottomHandleBar> createState() => _BottomHandleBarState();
}

class _BottomHandleBarState extends State<BottomHandleBar> {
  double opacity = 1.0;
  Timer? timer;
  late YsPlayStatus ysPlayStatus;

  late YsMediaType mediaType;
  bool get isFullScreen =>
      MediaQuery.of(context).orientation == Orientation.landscape;
  @override
  void initState() {
    super.initState();
    ysPlayStatus = widget.ysPlayStatus;
    mediaType = widget.mediaType;
    disappearAfter3s();
  }

  @override
  void didUpdateWidget(covariant BottomHandleBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (opacity == 0.0) {
      setState(() {
        opacity = 1.0;
      });
    }
    if (widget.ysPlayStatus != oldWidget.ysPlayStatus) {
      ysPlayStatus = widget.ysPlayStatus;
    }
    disappearAfter3s();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: GestureDetector(
        onTap: onTouchedHandle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: widget.width,
          height: widget.height,
          color: Colors.white.withOpacity(0.2),
          child: Row(
            children: [
              // 播放按钮
              JkPlayBtn(
                onTap: (status) => onPlayBtnClicked(status),
                ysPlayStatus: ysPlayStatus,
              ),

              // 声音按钮
              JkSoundBtn(onTap: (isOpen) => onSoundBtnClicked(isOpen)),

              // 清晰度设置
              JkLevelBtn(
                isShow: mediaType == YsMediaType.real,
                onSelectLevelHandle: (position) =>
                    onSelectLevelHandle(position),
              ),

              const Spacer(),

              // 全屏按钮
              FullScreenBtn(
                onTap: onFullScreenBtnClicked,
                isFullScreen: isFullScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3s后组件消失
  void disappearAfter3s() {
    if (timer != null) timer!.cancel();
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (t) {
        if (t.tick * 100 >= 5000) {
          // 3s后消失
          timer!.cancel();
          if (mounted) {
            setState(() {
              opacity = 0.0;
            });
          }
        }
      },
    );
  }

  /// 触碰组件任意一处，重新倒计时
  void onTouchedHandle() {
    if (opacity == 0.0) {
      setState(() {
        opacity = 1.0;
      });
      disappearAfter3s();
    }
  }

  ///播放按钮点击事件
  void onPlayBtnClicked(YsPlayStatus status) {
    onTouchedHandle();
    if (widget.onPlayHandle != null) widget.onPlayHandle!(status);
  }

  ///声音按钮点击事件
  void onSoundBtnClicked(bool isOpen) {
    onTouchedHandle();
    if (widget.onSoundHandle != null) widget.onSoundHandle!(isOpen);
  }

  /// 全屏按钮点击事件
  void onFullScreenBtnClicked() {
    if (widget.onFullScreenHandle != null) widget.onFullScreenHandle!();
  }

  /// 设置清晰度
  void onSelectLevelHandle(int position) {
    onTouchedHandle();
    if (widget.onSelectLevelHandle != null)
      widget.onSelectLevelHandle!(position);
  }
}
