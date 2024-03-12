// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:phone_cleaner/src/themes/themes.dart';

import '../../../commons/commons.dart';

class FileTile extends StatelessWidget {
  const FileTile({
    Key? key,
    required this.icon,
    required this.numberOfItems,
    required this.title,
    this.onPressed,
  }) : super(key: key);
  final CleanerIcon icon;
  final int numberOfItems;
  final String title;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          splashColor: cleanerColor.primary3,
          highlightColor: cleanerColor.primary2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox.square(dimension: 24, child: icon),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '$numberOfItems ',
                      style: semibold18.copyWith(color: cleanerColor.primary10),
                    ),
                    Text(
                      title,
                      style: regular14.copyWith(color: cleanerColor.neutral1),
                    ),
                  ],
                ),
                Icon(
                  Icons.navigate_next,
                  color: cleanerColor.primary7,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
