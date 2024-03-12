import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Background extends StatelessWidget {
  const Background({
    Key? key,
    this.secondaryBackground = false,
  }) : super(key: key);

  final bool secondaryBackground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: (MediaQuery.of(context).viewPadding.top +
              280 / 360 * MediaQuery.of(context).size.width) /
          0.6,
      child: SvgPicture.asset(
        secondaryBackground
            ? 'assets/images/bg.svg'
            : 'assets/images/bg_clip.svg',
        fit: BoxFit.fill,
      ),
    );
  }
}
