import 'package:phone_cleaner/src/commons/widgets/cleaner_icon.dart';
import 'package:flutter/material.dart';

import '../../themes/themes.dart';

class SettingItem extends StatelessWidget {
  final CleanerIcons icon;
  final String title;
  final Widget trailing;
  final Function() onTap;
  const SettingItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CleanerColor.of(context)!.neutral3,
      child: InkWell(
          onTap: onTap,
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    icon.toWidget(),
                    const SizedBox(width: 10),
                    Text(title, style: regular16)
                  ],
                ),
                trailing
              ],
            ),
          )),
    );
  }
}
