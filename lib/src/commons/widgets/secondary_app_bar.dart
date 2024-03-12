// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../themes/themes.dart';

class SecondaryAppBar extends StatelessWidget {
  const SecondaryAppBar({
    Key? key,
    required this.title,
    this.titleOpacity = 1,
    this.trailing,
  }) : super(key: key);

  final String title;
  final double titleOpacity;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    var cleanerColor = CleanerColor.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        pageHorizontalPadding,
        MediaQuery.of(context).viewPadding.top + 8,
        pageHorizontalPadding,
        0,
      ),
      child: SizedBox(
        height: appBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 32,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: 32,
                      height: 32,
                      // color: cleanerColor.primary7,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Opacity(
                  opacity: titleOpacity,
                  child: GradientText(
                    title,
                    style: bold20,
                    gradient: cleanerColor.gradient1,
                  ),
                ),
              ],
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
