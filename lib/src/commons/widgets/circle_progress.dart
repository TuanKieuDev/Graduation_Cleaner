import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgress extends CustomPainter {
  CircleProgress(this.currentProgress);

  final double currentProgress;

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    double angle = 2 * pi * (currentProgress / 100);
    Paint outerCircle = Paint()
      ..strokeWidth = 5
      ..color = const Color.fromRGBO(220, 230, 255, 1)
      ..style = PaintingStyle.stroke;

    Paint completeArcBackground = Paint()
      ..strokeWidth = 10
      ..color = const Color.fromRGBO(255, 255, 255, 1)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint completeArc = Paint()
      ..strokeWidth = 10
      ..shader = const LinearGradient(
        colors: [
          Color.fromRGBO(22, 110, 255, 1),
          Color.fromRGBO(66, 133, 244, 0.7),
        ],
      ).createShader(Rect.fromLTWH(0.0, 0.0, size.width / 2, size.height / 2))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint shadowPaint = Paint()
      ..color = const Color.fromRGBO(66, 133, 244, 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(
        center, radius, outerCircle); // this draws main outer circle

    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2 + 2, size.height / 2 + 2),
            radius: radius + 2),
        -pi / 2,
        angle,
        false,
        shadowPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        angle, false, completeArcBackground);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        angle, false, completeArc);
  }

  @override
  bool shouldRepaint(CircleProgress oldDelegate) =>
      oldDelegate.currentProgress != currentProgress;
}
