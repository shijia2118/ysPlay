import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ys_play/src/panel/sector_shape.dart';

class PanelPaint extends CustomPainter {
  final Offset offset;
  final Function()? onLeftTap;
  final Function()? onRightTap;
  final Function()? onTopTap;
  final Function()? onBottomTap;
  final double innerRadius;
  final double outerRadius;
  final Color? color;

  PanelPaint({
    required this.offset,
    this.onLeftTap,
    this.onBottomTap,
    this.onRightTap,
    this.onTopTap,
    this.innerRadius = 40,
    this.outerRadius = 100,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = .5
      ..color = color ?? Colors.grey
      ..style = PaintingStyle.stroke;

    Offset center = Offset(size.width / 2, size.height / 2); //中心点

    // 外圆
    Rect outCircle = Rect.fromCircle(center: center, radius: outerRadius);
    canvas.drawArc(
        outCircle, 0.0, 2 * pi, false, paint..style = PaintingStyle.stroke);

    // 内圆
    Rect innerCircle = Rect.fromCircle(center: center, radius: innerRadius);
    canvas.drawArc(innerCircle, 0.0, 2 * pi, false, paint);

    /// 左侧扇形
    /// 注：因为圆周的取值范围是-pi~pi.
    /// 该区域的取值范围是3pi/4~5pi/4 超出上述范围。
    /// 因此需要分段绘制。即:3pi/4~pi;-pi~-3pi/4
    SectorShape left = SectorShape(
      center: center,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      startAngle: 3 * pi / 4,
      sweepAngle: pi / 4,
    );
    SectorShape left2 = SectorShape(
      center: center,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      startAngle: -1 * pi,
      sweepAngle: pi / 4,
    );
    bool inLeftPie = left.contains(offset) || left2.contains(offset);
    Color leftPieColor = Colors.transparent;
    Color leftArrColor = Colors.grey;

    if (inLeftPie) {
      leftPieColor = Colors.grey;
      leftArrColor = Colors.white;
      if (onLeftTap != null) {
        onLeftTap!();
      }
    }
    canvas.drawPath(
      left.formPath(),
      paint
        ..style = PaintingStyle.fill
        ..color = leftPieColor,
    );
    canvas.drawPath(
      left2.formPath(),
      paint
        ..style = PaintingStyle.fill
        ..color = leftPieColor,
    );

    /// 右侧扇形
    SectorShape right = SectorShape(
      center: center,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      startAngle: -pi / 4,
      sweepAngle: pi / 2,
    );
    bool inRightPie = right.contains(offset);
    Color rightPieColor = Colors.transparent;
    Color rightArrColor = Colors.grey;

    if (inRightPie) {
      rightPieColor = Colors.grey;
      rightArrColor = Colors.white;
      if (onRightTap != null) onRightTap!();
    }
    canvas.drawPath(
      right.formPath(),
      paint
        ..style = PaintingStyle.fill
        ..color = rightPieColor,
    );

    /// 上方扇形
    SectorShape top = SectorShape(
      center: center,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      startAngle: -pi * 3 / 4,
      sweepAngle: pi / 2,
    );
    bool inTopPie = top.contains(offset);
    Color topPieColor = Colors.transparent;
    Color topArrColor = Colors.grey;

    if (inTopPie) {
      topPieColor = Colors.grey;
      topArrColor = Colors.white;
      if (onTopTap != null) onTopTap!();
    }
    canvas.drawPath(
      top.formPath(),
      paint
        ..style = PaintingStyle.fill
        ..color = topPieColor,
    );

    /// 下方扇形
    SectorShape bottom = SectorShape(
      center: center,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      startAngle: pi / 4,
      sweepAngle: pi / 2,
    );
    bool inBottomPie = bottom.contains(offset);
    Color bottomPieColor = Colors.transparent;
    Color bottomArrColor = Colors.grey;

    if (inBottomPie) {
      bottomPieColor = Colors.grey;
      bottomArrColor = Colors.white;
      if (onBottomTap != null) onBottomTap!();
    }
    canvas.drawPath(
      bottom.formPath(),
      paint
        ..style = PaintingStyle.fill
        ..color = bottomPieColor,
    );

    Paint paint2 = Paint()
      ..strokeWidth = 1
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    canvas.drawPath(left.arrowPath(), paint2..color = leftArrColor);
    canvas.drawPath(right.arrowPath(), paint2..color = rightArrColor);
    canvas.drawPath(top.arrowPath(), paint2..color = topArrColor);
    canvas.drawPath(bottom.arrowPath(), paint2..color = bottomArrColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
