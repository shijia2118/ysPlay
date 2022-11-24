import 'dart:math';

import 'package:flutter/material.dart';

class SectorShape {
  Offset center; // 中心点
  double innerRadius; // 小圆半径
  double outerRadius; // 大圆半径
  double startAngle; // 起始弧度
  double sweepAngle; // 扫描弧度

  SectorShape({
    required this.center,
    required this.innerRadius,
    required this.outerRadius,
    required this.startAngle,
    required this.sweepAngle,
  });

  Path formPath() {
    double startRad = startAngle;
    double endRad = startAngle + sweepAngle;

    double r0 = innerRadius;
    double r1 = outerRadius;
    Offset p0 = Offset(cos(startRad) * r0, sin(startRad) * r0);
    Offset p1 = Offset(cos(startRad) * r1, sin(startRad) * r1);
    Offset q0 = Offset(cos(endRad) * r0, sin(endRad) * r0);
    Offset q1 = Offset(cos(endRad) * r1, sin(endRad) * r1);

    bool large = sweepAngle.abs() > pi;
    bool clockwise = sweepAngle > 0;

    Path path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..arcToPoint(q1, radius: Radius.circular(r1), clockwise: clockwise, largeArc: large)
      ..lineTo(q0.dx, q0.dy)
      ..arcToPoint(p0, radius: Radius.circular(r0), clockwise: !clockwise, largeArc: large);
    return path.shift(center);
  }

  Path arrowPath() {
    double sideLen = 10;
    double arrAngle = 80 * pi / 180;
    double r0 = innerRadius;
    double r1 = outerRadius;
    double ringLen = r1 - r0; // 圆环半径
    double arrHeight = cos(arrAngle / 2) * sideLen; // 箭头高度
    double bottomLen = sideLen * sin(arrAngle / 2) * 2; // 箭头底边长度
    double diff = (ringLen - arrHeight) / 2;

    double p0x = 0.0;
    double p0y = 0.0;
    double p1x = 0.0;
    double p1y = 0.0;
    double p2x = 0.0;
    double p2y = 0.0;

    //左
    if (startAngle == 3 * pi / 4 || startAngle == -1 * pi) {
      p0x = -1 * (diff + innerRadius);
      p0y = -1 * (bottomLen / 2);
      p1x = -1 * (outerRadius - diff);
      p1y = 0;
      p2x = p0x;
      p2y = bottomLen / 2;
    } else if (startAngle == -pi / 4) {
      //右
      p0x = diff + innerRadius;
      p0y = -1 * (bottomLen / 2);
      p1x = outerRadius - diff;
      p1y = 0;
      p2x = p0x;
      p2y = bottomLen / 2;
    } else if (startAngle == -pi * 3 / 4) {
      //上
      p0x = -1 * (bottomLen / 2);
      p0y = -1 * (innerRadius + diff);
      p1x = 0;
      p1y = -1 * (outerRadius - diff);
      p2x = bottomLen / 2;
      p2y = -1 * (innerRadius + diff);
    } else if (startAngle == pi / 4) {
      //下
      p0x = -1 * (bottomLen / 2);
      p0y = innerRadius + diff;
      p1x = 0;
      p1y = outerRadius - diff;
      p2x = bottomLen / 2;
      p2y = innerRadius + diff;
    }

    Offset p0 = Offset(p0x, p0y);
    Offset p1 = Offset(p1x, p1y);
    Offset p2 = Offset(p2x, p2y);

    Path path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy);
    return path.shift(center);
  }

  bool contains(Offset p) {
    // 校验环形区域
    double l = (p - center).distance;
    bool inRing = l <= outerRadius && l >= innerRadius;
    if (!inRing) return false;

    // 校验角度范围
    double a = (p - center).direction;
    double endArg = startAngle + sweepAngle;
    double start = startAngle;

    if (a > pi) {
      start = start - 2 * pi;
      endArg = endArg - 2 * pi;
    }

    if (sweepAngle > 0) {
      return a >= start && a <= endArg;
    } else {
      return a <= start && a >= endArg;
    }
  }
}
