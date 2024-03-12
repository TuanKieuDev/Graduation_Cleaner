import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../commons/commons.dart';

class MainIcon extends StatelessWidget {
  const MainIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          const Positioned(
              top: 20, left: 20, child: CleanerIcon(icon: CleanerIcons.cloud1)),
          const Positioned(
            top: 70,
            right: 5,
            child: CleanerIcon(icon: CleanerIcons.cloud3),
          ),
          Positioned(
              bottom: -5,
              child: SvgPicture.asset('assets/icons/quick_boost.svg')),
        ],
      ),
    );
  }
}
