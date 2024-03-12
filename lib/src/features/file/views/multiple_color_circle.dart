import 'dart:math';

import 'package:flutter/material.dart';

class MultipleColorCircle extends CustomPainter {
  final int images;
  final Gradient gradientImages;
  final int videos;
  final Gradient gradientVideos;
  final int sounds;
  final Gradient gradientSounds;
  final int others;
  final Gradient gradientOthers;

  const MultipleColorCircle({
    this.images = 0,
    this.gradientImages =
        const LinearGradient(colors: [Colors.white, Colors.black]),
    this.videos = 0,
    this.gradientVideos =
        const LinearGradient(colors: [Colors.white, Colors.black]),
    this.sounds = 0,
    this.gradientSounds =
        const LinearGradient(colors: [Colors.white, Colors.black]),
    this.others = 0,
    this.gradientOthers =
        const LinearGradient(colors: [Colors.white, Colors.black]),
  });
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 14;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2 - strokeWidth / 2;

    int total = images + videos + sounds + others;

    Paint imagePaint = Paint()
      ..shader = gradientImages
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Paint videoPaint = Paint()
      ..shader = gradientVideos
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Paint soundPaint = Paint()
      ..shader = gradientSounds
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Paint othersPaint = Paint()
      ..shader = gradientOthers
          .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double imageLineRadianStart = -pi / 2;

    double imageLineRadianEnd = (360 * images / total) * pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      imageLineRadianStart,
      imageLineRadianEnd,
      false,
      imagePaint,
    );

    double videoLineRadianEnd = (360 * videos / total) * pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      imageLineRadianEnd - pi / 2,
      videoLineRadianEnd,
      false,
      videoPaint,
    );

    double soundLineRadianEnd = (360 * sounds / total) * pi / 180;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        imageLineRadianEnd + videoLineRadianEnd - pi / 2,
        soundLineRadianEnd,
        false,
        soundPaint);
    double otherLineRadianEnd = (360 * others / total) * pi / 180;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        imageLineRadianEnd + videoLineRadianEnd + soundLineRadianEnd - pi / 2,
        otherLineRadianEnd,
        false,
        othersPaint);
  }

  double getRadians(double value) {
    return (360 * value) * pi / 180;
  }

  @override
  bool shouldRepaint(MultipleColorCircle oldDelegate) =>
      oldDelegate.gradientImages != gradientImages ||
      oldDelegate.gradientVideos != gradientVideos ||
      oldDelegate.gradientSounds != gradientSounds ||
      oldDelegate.gradientOthers != gradientOthers ||
      oldDelegate.images != images ||
      oldDelegate.videos != videos ||
      oldDelegate.sounds != sounds ||
      oldDelegate.others != others;
}
