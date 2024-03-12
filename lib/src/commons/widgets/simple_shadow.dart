import 'dart:ui';
import 'package:flutter/material.dart';

class SimpleShadow extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;
  final Offset offset;
  final Alignment alignment;

  const SimpleShadow({
    super.key,
    this.blur = 2,
    this.color = Colors.black,
    this.offset = const Offset(2, 2),
    this.alignment = Alignment.center,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment,
      children: <Widget>[
        if (color.alpha != 0)
          Transform.translate(
            offset: offset,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                  sigmaY: blur, sigmaX: blur, tileMode: TileMode.decal),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 0,
                  ),
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(color, BlendMode.srcATop),
                  child: child,
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
