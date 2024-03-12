import 'dart:math';

import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:flutter/material.dart';

class CircleFourBreak extends CustomPainter {
  final DigitalUnit hiddenCacheSize;
  final DigitalUnit screenshotSize;
  final DigitalUnit thumbnailSize;
  final DigitalUnit emptyFolderSize;
  final Gradient hiddenCacheGradient;
  final Gradient screenshotGradient;
  final Gradient thumbnailGradient;
  final Gradient emptyFolderGradient;

  CircleFourBreak({
    required this.hiddenCacheSize,
    required this.screenshotSize,
    required this.thumbnailSize,
    required this.emptyFolderSize,
    this.hiddenCacheGradient =
        const LinearGradient(colors: [Colors.white, Colors.black]),
    this.screenshotGradient =
        const LinearGradient(colors: [Colors.white, Colors.black]),
    this.thumbnailGradient =
        const LinearGradient(colors: [Colors.white, Colors.black]),
    this.emptyFolderGradient =
        const LinearGradient(colors: [Colors.white, Colors.black]),
  });
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 5;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.height / 2;
    double breakSize = pi / 100;

    DigitalUnit total =
        hiddenCacheSize + screenshotSize + thumbnailSize + emptyFolderSize;

    Paint hiddenCachePaint = Paint()
      ..shader = hiddenCacheGradient
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Paint screenshotPaint = Paint()
      ..shader = screenshotGradient
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Paint thumbnailPaint = Paint()
      ..shader = thumbnailGradient
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Paint emptyFolderPaint = Paint()
      ..shader = emptyFolderGradient
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // 0
    double hiddenCacheLineRadianStart = -pi / 2;

    double hiddenCacheLineRadianEnd =
        (360 * hiddenCacheSize.value / total.value) * pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      hiddenCacheLineRadianStart,
      hiddenCacheLineRadianEnd - breakSize,
      false,
      hiddenCachePaint,
    );

    // 1
    double screenshotLineRadianEnd =
        (360 * screenshotSize.value / total.value) * pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      hiddenCacheLineRadianEnd - pi / 2,
      screenshotLineRadianEnd - breakSize,
      false,
      screenshotPaint,
    );

    // 2

    double thumbnailLineRadianEnd =
        (360 * thumbnailSize.value / total.value) * pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      hiddenCacheLineRadianEnd + screenshotLineRadianEnd - pi / 2,
      thumbnailLineRadianEnd - breakSize,
      false,
      thumbnailPaint,
    );

    // 3
    double emptyFolderLineRadianEnd =
        (360 * emptyFolderSize.value / total.value) * pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      hiddenCacheLineRadianEnd +
          screenshotLineRadianEnd +
          thumbnailLineRadianEnd -
          pi / 2,
      emptyFolderLineRadianEnd - breakSize,
      false,
      emptyFolderPaint,
    );
  }

  double getRadians(double value) {
    return (360 * value) * pi / 180;
  }

  @override
  bool shouldRepaint(CircleFourBreak oldDelegate) => false;
}
