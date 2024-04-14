import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScanningAnimation extends StatefulWidget {
  const ScanningAnimation({super.key});

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Lottie.asset('assets/lotties/star.json'),
          Lottie.asset('assets/lotties/icon_file_loading.json',
              width: constraints.maxWidth / 2),
        ],
      );
    });
  }
}
