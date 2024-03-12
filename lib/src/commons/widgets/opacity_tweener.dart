import 'package:flutter/material.dart';

class OpacityTweener extends StatelessWidget {
  const OpacityTweener({
    super.key,
    required this.child,
    required this.duration,
    this.curve = Curves.linear,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }
}
