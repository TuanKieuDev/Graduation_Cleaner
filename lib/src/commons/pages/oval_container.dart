import 'package:flutter/material.dart';

class OvalContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 15;

    var path = Path();

    path.moveTo(0, 90);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 90);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
