import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:ys_play/src/panel/panel_paint.dart';

class PanelView extends StatefulWidget {
  final Function()? onLeftTap;
  final Function()? onRightTap;
  final Function()? onTopTap;
  final Function()? onBottomTap;
  final Function()? onCanceled;
  final Function()? onInnerIconClicked;
  final double innerRadius;
  final double outerRadius;
  final Widget? innerIcon;

  const PanelView({
    super.key,
    this.onLeftTap,
    this.onBottomTap,
    this.onRightTap,
    this.onTopTap,
    this.onCanceled,
    this.onInnerIconClicked,
    this.innerRadius = 40,
    this.outerRadius = 100,
    this.innerIcon,
  });

  @override
  State<PanelView> createState() => _PanelViewState();
}

class _PanelViewState extends State<PanelView> {
  Offset p = Offset.zero;
  late double innerRadius; // 内圆半径
  late double outerRadius; // 外圆半径

  @override
  void initState() {
    super.initState();
    innerRadius = widget.innerRadius;
    outerRadius = widget.outerRadius;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: _onStart,
          onTapUp: (d) => _onStop(),
          onTapCancel: _onStop,
          child: SizedBox(
            width: outerRadius * 2,
            height: outerRadius * 2,
            child: CustomPaint(
              painter: PanelPaint(
                innerRadius: innerRadius,
                outerRadius: outerRadius,
                offset: p,
                onLeftTap: widget.onLeftTap,
                onRightTap: widget.onRightTap,
                onTopTap: widget.onTopTap,
                onBottomTap: widget.onBottomTap,
              ),
            ),
          ),
        ),
        Positioned(
          top: outerRadius - innerRadius,
          left: outerRadius - innerRadius,
          child: Visibility(
            visible: widget.innerIcon != null,
            child: GestureDetector(
              onTap: widget.onInnerIconClicked,
              child: Container(
                alignment: Alignment.center,
                width: innerRadius * 2,
                height: innerRadius * 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(innerRadius),
                ),
                child: widget.innerIcon,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onStart(TapDownDetails details) {
    p = details.localPosition;
    setState(() {});
  }

  void _onStop() {
    p = Offset.zero;
    setState(() {});
    if (widget.onCanceled != null) widget.onCanceled!();
  }

  /// 获取方向箭头url
  Future<ui.Image> getArrowUrl(String url) async {
    AssetImage assetImage = const AssetImage("assets/url.png");
    ImageStream stream = assetImage.resolve(createLocalImageConfiguration(context));
    Completer<ui.Image> completer = Completer();
    stream.addListener(ImageStreamListener((image, _) {
      return completer.complete(image.image);
    }));
    return completer.future;
  }
}
