import 'dart:math';

import 'package:flutter/material.dart';

class AppCircle extends CustomPainter {
  final int systemApp;
  final int installedApp;

  AppCircle({
    this.systemApp = 0,
    this.installedApp = 0,
  });
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 14;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.height / 2;

    int total = systemApp + installedApp;

    Paint firstPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color.fromRGBO(141, 203, 158, 1),
          Color.fromRGBO(51, 167, 82, 1),
        ],
      ).createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Paint secondPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color.fromRGBO(71, 104, 235, 1),
          Color.fromRGBO(45, 166, 255, 1),
        ],
      ).createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double firstLineRadianStart = -pi / 2;

    double firstLineRadianEnd = getRadians(systemApp, total);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      firstLineRadianStart,
      firstLineRadianEnd,
      false,
      firstPaint,
    );

    double secondLineRadianEnd = getRadians(installedApp, total);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      firstLineRadianEnd - pi / 2,
      secondLineRadianEnd,
      false,
      secondPaint,
    );
  }

  double getRadians(int value, int total) {
    return (360 * value / total) * pi / 180;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
