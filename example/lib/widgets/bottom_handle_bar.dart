import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ys_play_example/widgets/full_screen_btn.dart';
import 'package:ys_play_example/widgets/jk_level_btn.dart';
import 'package:ys_play_example/widgets/jk_sound_btn.dart';
import 'package:ys_play_example/ys_player.dart';

import 'jk_play_btn.dart';

class BottomHandleBar extends StatefulWidget {
  final double? width;
  final double? height;
  final Function(bool)? onPlayHandle;
  final Function(bool)? onSoundHandle;
  final Function()? onFullScreenHandle;
  final Function(int)? onSelectLevelHandle;
  final bool isPrepared;
  final JkMediaType mediaType;
  final Orientation orientation;
  const BottomHandleBar({
    Key? key,
    this.height,
    this.width,
    this.onFullScreenHandle,
    this.onPlayHandle,
    this.onSoundHandle,
    this.onSelectLevelHandle,
    required this.isPrepared,
    this.mediaType = JkMediaType.playback,
    this.orientation = Orientation.portrait,
  }) : super(key: key);

  @override
  State<BottomHandleBar> createState() => _BottomHandleBarState();
}

class _BottomHandleBarState extends State<BottomHandleBar> {
  double opacity = 1.0;
  Timer? timer;
  bool isPrepared = false;

  late JkMediaType mediaType;
  late Orientation orientation;

  @override
  void initState() {
    super.initState();
    isPrepared = widget.isPrepared;
    mediaType = widget.mediaType;
    orientation = widget.orientation;
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
    if (widget.isPrepared != oldWidget.isPrepared) {
      isPrepared = widget.isPrepared;
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
              // ????????????
              JkPlayBtn(
                onTap: (isPlaying) => onPlayBtnClicked(isPlaying),
                isPrepared: isPrepared,
              ),

              // ????????????
              JkSoundBtn(onTap: (isOpen) => onSoundBtnClicked(isOpen)),

              // ???????????????
              JkLevelBtn(
                isShow: mediaType == JkMediaType.real,
                onSelectLevelHandle: (position) => onSelectLevelHandle(position),
              ),

              const Spacer(),

              // ????????????
              FullScreenBtn(
                onTap: onFullScreenBtnClicked,
                orientation: orientation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3s???????????????
  void disappearAfter3s() {
    if (timer != null) timer!.cancel();
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (t) {
        if (t.tick * 100 >= 3000) {
          // 3s?????????
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

  /// ??????????????????????????????????????????
  void onTouchedHandle() {
    if (opacity == 0.0) {
      setState(() {
        opacity = 1.0;
      });
    }
    disappearAfter3s();
  }

  ///????????????????????????
  void onPlayBtnClicked(bool isPlaying) {
    onTouchedHandle();
    if (widget.onPlayHandle != null) widget.onPlayHandle!(isPlaying);
  }

  ///????????????????????????
  void onSoundBtnClicked(bool isOpen) {
    onTouchedHandle();
    if (widget.onSoundHandle != null) widget.onSoundHandle!(isOpen);
  }

  /// ????????????????????????
  void onFullScreenBtnClicked() {
    if (widget.onFullScreenHandle != null) widget.onFullScreenHandle!();
  }

  /// ???????????????
  void onSelectLevelHandle(int position) {
    onTouchedHandle();
    if (widget.onSelectLevelHandle != null) widget.onSelectLevelHandle!(position);
  }
}
