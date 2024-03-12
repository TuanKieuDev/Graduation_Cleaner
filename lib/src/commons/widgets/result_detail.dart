// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:phone_cleaner/share_styles/share_styles_file.dart';
import 'package:phone_cleaner/src/themes/cleaner_color.dart';
import 'package:flutter/material.dart';

import 'package:phone_cleaner/src/commons/commons.dart';

const iconSize = 48.0;

class ResultDetailArgs {
  final String title;
  final List<CleanResultData> results;

  ResultDetailArgs({
    required this.title,
    required this.results,
  });

  ResultDetailArgs copyWith({
    String? title,
    List<CleanResultData>? results,
  }) {
    return ResultDetailArgs(
      title: title ?? this.title,
      results: results ?? this.results,
    );
  }
}

class ResultDetail extends StatelessWidget {
  const ResultDetail({
    Key? key,
    required this.title,
    required this.results,
  }) : super(key: key);

  final String title;
  final List<CleanResultData> results;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SecondaryAppBar(title: title),
          const SizedBox(height: 8),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: pageHorizontalPadding),
            child: Text(
              '${results.length} ${results.length == 1 ? 'Item' : 'Items'}',
              style: semibold16.copyWith(color: cleanerColor.primary10),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: pageHorizontalPadding),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final data = results[index];
                Widget getIcon() {
                  if (data.icon != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(
                        data.icon!,
                        fit: BoxFit.cover,
                      ),
                    );
                  }

                  switch (data.iconReplacement!) {
                    case CleanResultIcons.photo:
                      return const CleanerIcon(icon: CleanerIcons.fileImage);
                    case CleanResultIcons.video:
                      return const CleanerIcon(icon: CleanerIcons.fileVideo);
                    case CleanResultIcons.file:
                      return const CleanerIcon(icon: CleanerIcons.file);
                    case CleanResultIcons.app:
                      return const Placeholder();
                  }
                }

                Widget icon = getIcon();
                icon = SizedBox.square(
                  dimension: iconSize,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: FractionallySizedBox(
                      heightFactor: data.icon != null ? 1 : 0.5,
                      child: icon,
                    ),
                  ),
                );

                const paddingHorizontal = 32;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width -
                                8 -
                                iconSize -
                                paddingHorizontal,
                            child: Text(
                              data.name,
                              style: regular14.copyWith(
                                color: cleanerColor.primary10,
                              ),
                            ),
                          ),
                          if (data.subtitle != null)
                            Text(
                              data.subtitle!,
                              style: semibold12.copyWith(
                                color: cleanerColor.neutral5,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
