import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/apps/models/models.dart';
import '../../themes/themes.dart';

class AppTipCheckboxItem extends StatelessWidget {
  const AppTipCheckboxItem({
    Key? key,
    required this.onTap,
    required this.data,
    this.onCheckboxTap,
    this.selectedColor,
    this.selectedBackgroundColor,
    this.radiusTop = false,
    this.showDataUsed = false,
    this.mimeType,
    this.padding = const EdgeInsets.symmetric(vertical: 0),
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
    final String subValue;
    switch (data.sortType) {
      case SortType.size:
        subValue = data.totalSize.toStringOptimal();
        break;
      case SortType.sizeChange:
        subValue = data.sizeChange.toStringOptimal();
        break;
      case SortType.name:
        subValue = data.name;
        break;
      case SortType.screenTime:
        subValue = data.totalTimeSpent.second.toStringOptimal();
        break;
      case SortType.batteryUse:
        subValue = '';
        break;
      case SortType.dataUse:
        subValue = data.dataUsed.toStringOptimal();
        break;
      case SortType.notification:
        subValue = '';
        break;
      case SortType.lastUsed:
        if (data.lastOpened != null) {
          subValue = DateFormat('HH:mm, dd/MM/yyy ').format(
            data.lastOpened!,
          );
        } else {
          subValue = 'Unused';
        }
        // } else {
        //   subValue = 'Unused';
        // }

        break;
      case SortType.timeOpened:
        subValue = data.timeOpened.toString();
        break;
      case SortType.unused:
        subValue = data.totalSize.toStringOptimal();
        break;
    }
    return Material(
      color: data.checked ? cleanerColor.primary1 : cleanerColor.neutral3,
      child: InkWell(
        onTap: onCheckboxTap ?? onTap,
        child: Container(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.memory(
                data.iconData!,
                width: 42,
                height: 42,
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Text(
                  data.name,
                  style: regular16.copyWith(color: cleanerColor.primary10),
                ),
              ),
              Text(
                subValue,
                style: regular14.copyWith(
                  color: data.checked
                      ? cleanerColor.primary7
                      : cleanerColor.neutral1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: cleanerColor.neutral4,
                ),
                child: Transform.scale(
                  scale: 1.25,
                  child: Checkbox(
                    value: data.checked,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: cleanerColor.selectedColor,
                    onChanged: (value) {
                      onCheckboxTap != null ? onCheckboxTap!() : onTap();
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
