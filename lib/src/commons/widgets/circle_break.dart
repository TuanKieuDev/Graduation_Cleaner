import 'dart:math';

import 'package:phone_cleaner/src/commons/models/digital_unit.dart';
import 'package:flutter/material.dart';

class CircleBreak extends CustomPainter {
  final DigitalUnit appSize;
  final Gradient gradientApp;
  final DigitalUnit dataSize;
  final Gradient gradientData;
  final DigitalUnit cacheSize;
  final Gradient gradientCache;

  CircleBreak({
    required this.appSize,
    this.gradientApp =
        const LinearGradient(colors: [Colors.white, Colors.black]),
    required this.dataSize,
    this.gradientData =
        const LinearGradient(colors: [Colors.white, Colors.black]),
    required this.cacheSize,
    this.gradientCache =
        const LinearGradient(colors: [Colors.white, Colors.black]),
  });
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 5;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.height / 2;
    double breakSize = pi / 100;

    DigitalUnit total = appSize + dataSize + cacheSize;

    Paint appPaint = Paint()
      ..shader = gradientApp
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Paint dataPaint = Paint()
      ..shader = gradientData
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Paint cachePaint = Paint()
      ..shader = gradientCache
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double appLineRadianStart = -pi / 2;

    double appLineRadianEnd = (360 * appSize.value / total.value) * pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      appLineRadianStart,
      appLineRadianEnd - breakSize,
      false,
      appPaint,
    );

    double dataLineRadianEnd = (360 * dataSize.value / total.value) * pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      appLineRadianEnd - pi / 2,
      dataLineRadianEnd - breakSize,
      false,
      dataPaint,
    );

    double cacheLineRadianEnd =
        (360 * cacheSize.value / total.value) * pi / 180;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        appLineRadianEnd + dataLineRadianEnd - pi / 2,
        cacheLineRadianEnd - breakSize,
        false,
        cachePaint);
  }

  double getRadians(double value) {
    return (360 * value) * pi / 180;
  }

  @override
  bool shouldRepaint(CircleBreak oldDelegate) => false;
}
