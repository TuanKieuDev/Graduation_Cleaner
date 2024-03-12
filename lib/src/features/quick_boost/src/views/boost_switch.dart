import 'package:flutter/material.dart';

import '../../../../themes/themes.dart';

class BoostSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const BoostSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  State createState() => _BoostSwitchState();
}

class _BoostSwitchState extends State<BoostSwitch>
    with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutQuad));
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
            onTap: _onChanged,
            child: Container(
              width: 100.0,
              height: 20.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color.fromRGBO(190, 190, 190, 1),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Off",
                          style: semibold12.copyWith(
                            color: const Color.fromRGBO(155, 155, 155, 1),
                          ),
                        ),
                        Text(
                          "On",
                          style: semibold12.copyWith(
                            color: const Color.fromRGBO(155, 155, 155, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: _circleAnimation.value,
                    child: Container(
                      alignment: Alignment.center,
                      width: 56.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          // color: CleanerColor.of(context)!.neutral3,
                          gradient: CleanerColor.of(context)!.gradient1,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                                blurRadius: 2,
                                offset: Offset(-1, 1),
                                color: Color.fromRGBO(0, 0, 0, 0.15))
                          ]),
                      child: Text(
                        _circleAnimation.value == Alignment.centerLeft
                            ? "Off"
                            : "On",
                        style: semibold12.copyWith(
                          color: CleanerColor.of(context)!.neutral3,
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
