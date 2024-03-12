import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/commons/utilities/app_checkbox_item_extension.dart';
import 'package:flutter/material.dart';

import '../../themes/themes.dart';

class AppCheckboxItem extends StatelessWidget {
  const AppCheckboxItem({
    Key? key,
    required this.onTap,
    required this.data,
    this.onCheckboxTap,
    this.selectedColor,
    this.selectedBackgroundColor,
    this.radiusTop = false,
    this.showDataUsed = false,
    this.mimeType,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  }) : super(key: key);

  final AppCheckboxItemData data;
  final Function() onTap;
  final Function()? onCheckboxTap;
  final EdgeInsets? padding;
  final bool radiusTop;
  final bool showDataUsed;
  final String? mimeType;
  final Color? selectedColor;
  final Color? selectedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    late String nameOptimal;
    if ((data.name.length > 30)) {
      nameOptimal = '${data.name.substring(0, 25)}...';
    } else {
      nameOptimal = data.name;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: data.checked ? cleanerColor.primary1 : cleanerColor.neutral3,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              data.iconData!,
              cacheHeight:
                  (MediaQuery.of(context).devicePixelRatio * 48).toInt(),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 16),
        minLeadingWidth: 0,
        horizontalTitleGap: 8,
        title: Text(
          nameOptimal,
          style: semibold14.copyWith(
            color: cleanerColor.primary10,
          ),
        ),
        subtitle: Text(
          data.subValue,
          style: regular12.copyWith(
            color: data.checked ? cleanerColor.primary7 : cleanerColor.neutral1,
          ),
        ),
        trailing: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: cleanerColor.neutral4,
              ),
              child: Checkbox(
                value: data.checked,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: cleanerColor.selectedColor,
                onChanged: (value) {},
              ),
            ),
            IconButton(
              onPressed: () {
                onCheckboxTap != null ? onCheckboxTap!() : onTap();
              },
              icon: const SizedBox(
                width: 16,
                height: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
