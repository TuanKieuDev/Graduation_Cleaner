import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../themes/themes.dart';
import '../commons.dart';

class GrowingApp extends StatelessWidget {
  const GrowingApp({
    Key? key,
    this.isCenter = false,
    required this.size,
    required this.iconData,
  }) : super(key: key);

  final DigitalUnit size;
  final Uint8List iconData;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    final iconSize = MediaQuery.of(context).size.width * 2 / 9;

    Gradient gradient;
    Color trapeziumColor;

    if (size < 500.mb) {
      gradient = cleanerColor.gradient3;
      trapeziumColor = const Color.fromRGBO(118, 196, 139, 0.5);
    } else if (size < 1.gb) {
      gradient = cleanerColor.gradient2;
      trapeziumColor = const Color.fromRGBO(255, 127, 49, 0.5);
    } else {
      gradient = cleanerColor.gradient4;
      trapeziumColor = const Color.fromRGBO(248, 70, 74, 0.5);
    }

    final imgSize = isCenter ? iconSize : iconSize - 16;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 10,
          child: CustomPaint(
            painter: TrapeziumPainter(color: trapeziumColor),
            size: isCenter
                ? Size(iconSize, iconSize)
                : Size(iconSize - 14, iconSize - 14),
          ),
        ),
        Column(
          children: [
            Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(
                  minWidth: isCenter ? iconSize : iconSize - 14,
                  maxWidth: iconSize + 10),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              height: isCenter ? 24 : 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: gradient,
              ),
              child: Text(
                "${size >= 0.bytes ? '+' : '-'}${size.value.abs().bytes.toStringOptimal()}",
                style: semibold12.copyWith(color: cleanerColor.neutral3),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: imgSize,
              height: imgSize,
              decoration: BoxDecoration(
                color: cleanerColor.neutral3,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: cleanerColor.neutral4.withOpacity(0.5),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Image.memory(
                    iconData,
                    cacheHeight:
                        (imgSize * MediaQuery.of(context).devicePixelRatio)
                            .toInt(),
                  )),
            ),
          ],
        ),
      ],
    );
  }
}

class TrapeziumPainter extends CustomPainter {
  const TrapeziumPainter({required this.color});

  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 15;

    var path = Path();

    path.moveTo(0, 0);

    path.lineTo(size.width / 4, size.height / 2);
    path.lineTo(size.width * 3 / 4, size.height / 2);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
