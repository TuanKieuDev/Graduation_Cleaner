// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/themes/themes.dart';

class FileGridItem extends StatelessWidget {
  const FileGridItem({
    super.key,
    required this.data,
    this.smallItem = false,
    this.onPressed,
    this.onLongPressed,
    required this.onCheckboxPressed,
    this.onPreviewPressed,
  });

  final FileCheckboxItemData? data;
  final bool smallItem;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final ValueSetter<CheckboxStatus> onCheckboxPressed;
  final VoidCallback? onPreviewPressed;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          ),
          child: Column(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth,
                child: FileGridItemIcon(
                  data: data,
                  height: constraints.maxWidth,
                  width: constraints.maxWidth,
                  onPreviewPressed: onPreviewPressed,
                  onLongPressed: onLongPressed,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  mainAxisAlignment: smallItem
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    if (!smallItem && data != null)
                      Text(
                        data!.size.toStringOptimal(),
                        style: semibold12.copyWith(
                          color: data!.checked
                              ? cleanerColor.primary7
                              : cleanerColor.neutral5,
                        ),
                      ),
                    CleanCheckbox(
                      onChanged: onCheckboxPressed,
                      checkboxStatus: data?.checked ?? false
                          ? CheckboxStatus.checked
                          : CheckboxStatus.unchecked,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FileGridItemIcon extends StatelessWidget {
  const FileGridItemIcon({
    Key? key,
    required this.data,
    this.selected,
    required this.width,
    required this.height,
    this.onPreviewPressed,
    this.onLongPressed,
  }) : super(key: key);

  final FileCheckboxItemData? data;
  final bool? selected;
  final double width;
  final double height;
  final VoidCallback? onPreviewPressed;
  final VoidCallback? onLongPressed;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          FilePreview(
            data: data,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                width: selected ?? data?.checked ?? false ? 2 : 0,
                color: selected ?? data?.checked ?? false
                    ? cleanerColor.primary7
                    : cleanerColor.primary1,
              ),
            ),
          ),
          TextButton(
            onPressed: onPreviewPressed,
            onLongPress: onLongPressed,
            style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
            child: SizedBox(
              // TODO: kiểm tra xem có cần dùng constrains hay không
              width: width,
              height: height,
            ),
          )
        ],
      ),
    );
  }
}
