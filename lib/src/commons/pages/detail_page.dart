// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import 'package:phone_cleaner/share_styles/share_styles_file.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/themes/cleaner_color.dart';

class DetailPageArgs {
  const DetailPageArgs({
    required this.name,
    required this.path,
    required this.size,
    required this.lastModified,
    this.mimeType,
    this.isCanOpen = true,
  });
  final String name;
  final String path;
  final int size;
  final String? mimeType;
  final DateTime lastModified;
  final bool isCanOpen;
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.args});

  final DetailPageArgs args;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Text(
              "More Details",
              style: semibold18.copyWith(color: cleanerColor.primary10),
            ),
          ),
        ),
        const SizedBox(
          height: 48,
        ),
        _InformationItem(
          title: "Name",
          value: args.name,
        ),
        _InformationItem(
          title: "Path",
          value: args.path,
        ),
        _InformationItem(
          title: "Size",
          value: args.size.bytes.toStringOptimal(),
        ),
        _InformationItem(
          title: "Last modified",
          value: DateFormat('HH:mm, dd/MM/yyy ').format(
            args.lastModified,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: (args.isCanOpen)
              ? PrimaryButton(
                  title: Text(
                    "OPEN FILE",
                    style: bold18.copyWith(color: cleanerColor.neutral3),
                  ),
                  width: double.maxFinite,
                  borderRadius: BorderRadius.circular(24),
                  onPressed: () {
                    final result =
                        OpenFilex.open(args.path, type: args.mimeType);
                    if (kDebugMode) {
                      result.then((value) => debugPrint(value.message));
                      // debugPrint(result);
                    }
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _InformationItem extends StatelessWidget {
  const _InformationItem({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: regular14.copyWith(color: cleanerColor.neutral5),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                value,
                style: semibold14.copyWith(
                  color: cleanerColor.primary10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: double.infinity,
          height: 20,
        ),
        // Divider(
        //   height: 20,
        //   color: cleanerColor.neutral5,
        // )
      ],
    );
  }
}
