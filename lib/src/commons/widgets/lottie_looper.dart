// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:monetization/monetization.dart';

class LottieLooper extends StatefulWidget {
  const LottieLooper(
    this.path, {
    Key? key,
    this.loop = true,
    this.width = 100,
    this.height = 100,
    this.child,
    this.onStop,
    this.stopTargets = const [1],
    this.description = '',
  }) : super(key: key);

  final bool loop;
  final double width;
  final double height;
  final Widget? child;
  final VoidCallback? onStop;
  final String path;
  final List<double> stopTargets;
  final String description;

  @override
  State<LottieLooper> createState() => _LottieLooperState();
}

class _LottieLooperState extends State<LottieLooper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _processingAnimationController =
      AnimationController(vsync: this);

  static const fadeOutDuration = Duration(milliseconds: 300);

  bool _loopingAnimationFinished = false;
  double _opacity = 1;

  @override
  void dispose() {
    _processingAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LottieLooper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loop == widget.loop) return;

    _runAnimation();
  }

  void _runAnimation() async {
    if (_processingAnimationController.duration == null) return;

    if (widget.loop) {
      _processingAnimationController.repeat();
    } else {
      final value = _processingAnimationController.value;
      double stopTarget = widget.stopTargets.first;

      for (var element in widget.stopTargets) {
        if (element > value) {
          stopTarget = element;
          break;
        }
      }

      if (value > stopTarget) {
        await _processingAnimationController.forward();
        _processingAnimationController.value = 0;
      }

      if (!mounted) {
        return;
      }
      _processingAnimationController.animateTo(stopTarget);
      _processingAnimationController
          .addStatusListener(_listenToAnimationStatus);
    }
  }

  void _listenToAnimationStatus(status) {
    if (_loopingAnimationFinished) return;
    if (widget.loop) return;
    if (status != AnimationStatus.completed) {
      return;
    }

    setState(() {
      _loopingAnimationFinished = true;
      _opacity = 0;
    });

    _processingAnimationController
        .removeStatusListener(_listenToAnimationStatus);

    Future.delayed(fadeOutDuration).then((value) {
      widget.onStop?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final starAnimation =
        Lottie.asset('assets/lotties/star.json', fit: BoxFit.cover);
    final loadingIcon = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          widget.path,
          width: widget.width,
          height: widget.height,
          controller: _processingAnimationController,
          onLoaded: (lottieComposition) {
            _processingAnimationController.duration =
                lottieComposition.duration;
            _processingAnimationController.value = 0;
            _runAnimation();
          },
        ),
        const SizedBox.square(dimension: 16),
        Text(
          widget.description,
          style:
              semibold18.copyWith(color: CleanerColor.of(context)!.primary10),
        ),
      ],
    );

    final loadingIndicator = Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        starAnimation,
        loadingIcon,
      ],
    );

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (_loopingAnimationFinished && widget.child != null) widget.child!,
          OpacityTweener(
            duration: fadeOutDuration,
            child: AnimatedOpacity(
              curve: Curves.easeOutQuad,
              opacity: _opacity,
              duration: fadeOutDuration,
              child: loadingIndicator,
            ),
          ),
        ],
      ),
    );
  }
}
