// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:phone_cleaner/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phone_cleaner/src/commons/commons.dart';

import '../../../share_styles/share_styles_file.dart';
import '../pages/detail_page.dart';

class FileCheckboxItem extends StatelessWidget {
  const FileCheckboxItem({
    Key? key,
    required this.onTap,
    required this.data,
    this.selectedColor,
    this.selectedBackgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  }) : super(key: key);

  final FileCheckboxItemData data;
  final Function() onTap;
  final EdgeInsets padding;
  final Color? selectedColor;
  final Color? selectedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    void openDetail() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints.loose(MediaQuery.of(context).size),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        builder: (context) {
          return DetailPage(
              args: DetailPageArgs(
            name: data.name,
            path: data.path,
            size: data.size.to(DigitalUnitSymbol.byte).value.toInt(),
            lastModified: data.timeModified,
            isCanOpen: data.isFolder ? false : true,
          ));
        },
      );
    }

    return CheckboxItem(
      key: key,
      onTap: onTap,
      onLongPress: () => openDetail(),
      onCheckboxTap: onTap,
      leading: data.isApp
          ? AppIcon(packageName: data.extensionFile)
          : data.extensionFile != ''
              ? Container(
                  alignment: Alignment.center,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(219, 219, 219, 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data.extensionFile,
                    style: semibold12,
                  ),
                )
              : const SizedBox.shrink(),
      title: data.name,
      checked: data.checked,
      selectedBackgroundColor: selectedBackgroundColor,
      selectedColor: selectedColor,
      trailingValue: data.size.toStringOptimal(),
      padding: padding,
    );
  }
}

class AppIcon extends ConsumerWidget {
  const AppIcon({
    super.key,
    required this.packageName,
    this.size = 32,
  });

  final String packageName;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(appRepository).getIcon(packageName),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.square(dimension: 32);
        }

        return Image.memory(
          snapshot.requireData,
          height: size,
          width: size,
          cacheHeight: (MediaQuery.of(context).devicePixelRatio * size).toInt(),
        );
      },
    );
  }
}
