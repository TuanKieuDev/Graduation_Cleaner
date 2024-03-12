// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProcessingLottie extends StatefulWidget {
  const ProcessingLottie({
    Key? key,
    required this.path,
    this.stopValue,
    this.onComplete,
  }) : super(key: key);

  final String path;
  final double? stopValue;
  final VoidCallback? onComplete;

  @override
  State<ProcessingLottie> createState() => _ProcessingLottieState();
}

class _ProcessingLottieState extends State<ProcessingLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this);

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    if (!loaded) return;

    _animationController.repeat();
    if (widget.stopValue != null) {
      _animationController.animateTo(widget.stopValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateAnimation();
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Lottie.asset(widget.path,
              width: double.infinity,
              fit: BoxFit.cover,
              controller: _animationController, onLoaded: (e) {
            _animationController.duration = e.duration;
            setState(() => loaded = true);
          }, delegates: LottieDelegates(text: (p0) {
            return p0;
          })),
        ),
      ],
    );
  }
}
