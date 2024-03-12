import 'package:flutter/material.dart';
import '../../../commons/commons.dart';
import '../../../themes/themes.dart';

const double messageLabelIconSize = 40;

class MessageLabel extends StatelessWidget {
  const MessageLabel({super.key, required this.size});

  final DigitalUnit size;

  @override
  Widget build(BuildContext context) {
    if (size < 100.mb) {
      return Stack(
        alignment: Alignment.center,
        children: [
          const CleanerIcon(
            icon: CleanerIcons.messageLabel1,
            size: 40,
          ),
          _Content(size: size),
        ],
      );
    } else if (size < 1.gb) {
      return Stack(
        alignment: Alignment.center,
        children: [
          const CleanerIcon(
            icon: CleanerIcons.messageLabel2,
            size: messageLabelIconSize,
          ),
          _Content(size: size),
        ],
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          const CleanerIcon(
            icon: CleanerIcons.messageLabel3,
            size: 40,
          ),
          _Content(size: size),
        ],
      );
    }
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.size,
  }) : super(key: key);

  final DigitalUnit size;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        size.toStringOptimal(),
        style: semibold12.copyWith(color: cleanerColor.neutral3),
      ),
    );
  }
}
