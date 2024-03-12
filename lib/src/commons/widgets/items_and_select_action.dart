import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../themes/themes.dart';
import '../commons.dart';

class ItemsAndSelectAction extends ConsumerWidget {
  const ItemsAndSelectAction({
    super.key,
    required this.displayName,
    required this.totalSize,
    required this.isAllChecked,
    required this.onPressed,
  });

  final String displayName;
  final DigitalUnit totalSize;
  final bool isAllChecked;
  final Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cleanerColor = CleanerColor.of(context)!;
    final names = displayName.split(" ");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              text: "${names[0]} ",
              style: semibold16.copyWith(color: cleanerColor.primary10),
              children: <TextSpan>[
                for (int i = 1; i < names.length; i++)
                  TextSpan(
                    text: "${names[i]} ",
                    style: regular12.copyWith(color: cleanerColor.primary10),
                  ),
                TextSpan(
                  text: "${totalSize.toOptimal().toString()} ",
                  style: semibold16.copyWith(color: cleanerColor.primary10),
                ),
                TextSpan(
                  text: totalSize.closestOptimalUnit.toString(),
                  style: regular12.copyWith(color: cleanerColor.primary10),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: const Color.fromRGBO(66, 133, 244, 0.2),
              foregroundColor: const Color.fromRGBO(150, 202, 255, 0.3),
            ),
            child: Text(
              isAllChecked ? "Deselect all" : "Select all",
              style: semibold14.copyWith(color: cleanerColor.primary7),
            ),
          ),
        ],
      ),
    );
  }
}
