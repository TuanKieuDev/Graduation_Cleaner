import 'package:flutter/material.dart';

import '../../themes/themes.dart';

class CheckboxItem extends StatelessWidget {
  const CheckboxItem({
    Key? key,
    this.onTap,
    this.onLongPress,
    this.onCheckboxTap,
    this.leading,
    this.title = "",
    this.trailingValue = "",
    this.checked = false,
    this.selectedColor,
    this.selectedBackgroundColor,
    required this.padding,
  }) : super(key: key);

  final Widget? leading;
  final String title;
  final String trailingValue;
  final bool checked;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function()? onCheckboxTap;
  final EdgeInsets padding;
  final Color? selectedColor;
  final Color? selectedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return LayoutBuilder(builder: (context, constraints) {
      return Material(
        color: checked
            ? selectedBackgroundColor ?? cleanerColor.primary1
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: padding,
            decoration: const BoxDecoration(color: Colors.transparent),
            width: double.maxFinite,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (leading != null) leading!,
                    const SizedBox(width: 8),
                    SizedBox(
                      width: constraints.maxWidth - 200,
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: regular16.copyWith(
                          color: cleanerColor.primary10,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      trailingValue,
                      style: TextStyle(
                        fontSize: 16,
                        color: checked
                            ? cleanerColor.primary7
                            : cleanerColor.neutral5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: cleanerColor.neutral4,
                      ),
                      child: Checkbox(
                        value: checked,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        activeColor: cleanerColor.selectedColor,
                        onChanged: (value) => onCheckboxTap?.call(),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
