import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:monetization/monetization.dart';

class ProcessAndResultLottie extends ConsumerStatefulWidget {
  const ProcessAndResultLottie({
    super.key,
    this.lottiePath = 'assets/lotties/cleaning.json',
    this.loop = true,
    this.child,
  });

  final String lottiePath;
  final bool loop;
  final Widget? child;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _QuickCleanProcessAndResultPageState();
}

class _QuickCleanProcessAndResultPageState
    extends ConsumerState<ProcessAndResultLottie>
    with SingleTickerProviderStateMixin {
  static const _processingLoopDuration = 454 / 575;

  bool _loopingAnimationFinished = false;

  late final AnimationController _processingAnimationController =
      AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();

    _processingAnimationController.addListener(() {
      if (_loopingAnimationFinished) return;
      if (widget.loop) return;
      if (_processingAnimationController.value < _processingLoopDuration) {
        return;
      }

      setState(() {
        _loopingAnimationFinished = true;
      });
    });

    _processingAnimationController.addListener(() {
      if (!widget.loop && _processingAnimationController.value == 1) {
        AdManager.instance
            .showAds(AdType.interstitial, "quick_clean_finished_processing");
      }
    });
  }

  @override
  void dispose() {
    _processingAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProcessAndResultLottie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loop == widget.loop) return;

    _runAnimation();
  }

  void _runAnimation() {
    if (_processingAnimationController.duration == null) return;

    if (widget.loop) {
      _processingAnimationController.repeat(max: _processingLoopDuration);
    } else {
      _processingAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_loopingAnimationFinished)
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: _processingAnimationController.duration! *
                  ((1 - _processingLoopDuration)),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: widget.child,
            ),
          IgnorePointer(
            child: Center(
              child: Lottie.asset(
                widget.lottiePath, // size = 360 x 800
                width: double.infinity,
                fit: BoxFit.cover,
                controller: _processingAnimationController,
                onLoaded: (lottieComposition) {
                  _processingAnimationController.duration =
                      lottieComposition.duration;
                  _runAnimation();
                },
              ),
            ),
          ),
          if (!_loopingAnimationFinished)
            const Positioned(
              bottom: 0,
              child: BannerAd(),
            ),
        ],
      ),
    );
  }
}
