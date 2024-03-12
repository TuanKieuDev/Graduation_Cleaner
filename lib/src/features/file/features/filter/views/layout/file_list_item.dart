import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FileListItem extends StatelessWidget {
  const FileListItem({
    super.key,
    required this.data,
    this.onPressed,
    this.onLongPressed,
    required this.onCheckboxPressed,
    this.onPreviewPressed,
  });

  final FileCheckboxItemData? data;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final ValueSetter<CheckboxStatus> onCheckboxPressed;
  final VoidCallback? onPreviewPressed;

  @override
  Widget build(BuildContext context) {
    final data = this.data;

    final cleanerColor = CleanerColor.of(context)!;

    late String nameOptimal;
    if (data == null) {
      nameOptimal = '';
    } else if ((data.name.length > 20)) {
      nameOptimal = '${data.name.substring(0, 15)}...';
    } else {
      nameOptimal = data.name;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: data?.checked ?? false
            ? cleanerColor.primary1
            : cleanerColor.neutral3,
      ),
      child: ListTile(
        onTap: onPressed,
        onLongPress: onLongPressed,
        leading: GestureDetector(
          onTap: onPreviewPressed,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 2,
                color: data?.checked ?? false
                    ? cleanerColor.primary7
                    : cleanerColor.primary1,
              ),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: FilePreview(data: data)),
          ),
        ),
        minLeadingWidth: 0,
        horizontalTitleGap: 8,
        title: Text(
          data != null ? data.name : '',
          overflow: TextOverflow.ellipsis,
          style: semibold14.copyWith(
            color: cleanerColor.primary10,
          ),
        ),
        subtitle: (data != null)
            ? RichText(
                text: TextSpan(
                  text: DateFormat('HH:mm, dd/MM/yyy ').format(
                    data.timeModified,
                  ),
                  style: regular12.copyWith(color: cleanerColor.neutral1),
                  children: <TextSpan>[
                    TextSpan(
                      text: data.size.toStringOptimal(),
                      style: semibold12.copyWith(
                        color: data.checked
                            ? cleanerColor.primary7
                            : cleanerColor.neutral5,
                      ),
                    ),
                  ],
                ),
              )
            : const Text(''),
        trailing: CleanCheckbox(
          onChanged: onCheckboxPressed,
          checkboxStatus: data?.checked ?? false
              ? CheckboxStatus.checked
              : CheckboxStatus.unchecked,
        ),
      ),
    );
  }
}
