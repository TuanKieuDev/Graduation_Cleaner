import 'package:flutter/material.dart';

import '../../../themes/themes.dart';

class TimeSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const TimeSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.onComplete,
  }) : super(key: key);

  final Function()? onComplete;

  @override
  State createState() => _TimeSwitchState();
}

class _TimeSwitchState extends State<TimeSwitch>
    with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOut)
          ..addStatusListener((AnimationStatus status) {
            if (status != AnimationStatus.forward ||
                status != AnimationStatus.reverse) {
              widget.onComplete!();
            }
          }));
  }

  void _onChanged() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
            onTap: _onChanged,
            child: Container(
              width: 150.0,
              height: 24.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: const Color.fromRGBO(223, 223, 223, 1),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "7 days",
                          key: const ValueKey(0),
                          style: semibold12.copyWith(
                            color: const Color.fromRGBO(183, 183, 183, 1),
                          ),
                        ),
                        Text(
                          "24 hours",
                          key: const ValueKey(1),
                          style: semibold12.copyWith(
                            color: const Color.fromRGBO(183, 183, 183, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: _circleAnimation.value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      alignment: Alignment.center,
                      width: _circleAnimation.value == Alignment.centerLeft ||
                              _animationController.status ==
                                  AnimationStatus.forward
                          ? 75
                          : 85,
                      height: 24.0,
                      decoration: BoxDecoration(
                          gradient: cleanerColor.gradient1,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                              color: cleanerColor.textDisable,
                            )
                          ]),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _circleAnimation.value == Alignment.centerLeft ||
                                  _animationController.status ==
                                      AnimationStatus.forward
                              ? "7 days"
                              : "24 hours",
                          style: semibold12.copyWith(
                            color: cleanerColor.neutral3,
                          ),
                          key: ValueKey(_animationController.status),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
