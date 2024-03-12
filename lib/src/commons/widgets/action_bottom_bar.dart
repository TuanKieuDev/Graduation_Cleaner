import 'package:flutter/material.dart';

import '../../themes/themes.dart';
import '../commons.dart';

class ActionBottomBar extends StatelessWidget {
  const ActionBottomBar({
    Key? key,
    required this.selectedCount,
    required this.checkedSize,
    required this.actions,
  }) : super(key: key);

  final int selectedCount;
  final DigitalUnit checkedSize;
  final List<ActionButton> actions;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    var title = RichText(
      text: TextSpan(
        text: selectedCount.toString(),
        style: TextStyle(color: cleanerColor.primary6),
        children: <TextSpan>[
          TextSpan(
            text: ' Selected ',
            style: DefaultTextStyle.of(context).style,
          ),
          TextSpan(
            text: "(${checkedSize.toStringOptimal()})",
          ),
        ],
      ),
    );

    return AnimatedContainer(
      width: double.maxFinite,
      height: selectedCount > 0 ? 90 : 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: cleanerColor.neutral3,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(66, 133, 244, 0.2),
            blurRadius: 4,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          title,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions,
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.onPressed,
    this.isExpanded = false,
    this.titleStyle,
    this.isEnable = true,
  }) : super(key: key);

  final Widget icon;
  final String title;
  final TextStyle? titleStyle;
  final VoidCallback onPressed;
  final bool isExpanded;
  final bool isEnable;
  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return isExpanded
        ? _buildExpandedButton(cleanerColor)
        : _buildBasicButton(cleanerColor);
  }

  Widget _buildExpandedButton(CleanerColor cleanerColor) => Expanded(
        child: GestureDetector(
          onTap: isEnable ? onPressed : () {},
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: cleanerColor.primary3,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  title,
                  style: semibold12.copyWith(color: cleanerColor.primary10),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildBasicButton(CleanerColor cleanerColor) {
    return TextButton(
      onPressed: isEnable ? onPressed : () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isEnable
              ? icon
              : Icon(
                  Icons.lock_outline,
                  color: cleanerColor.neutral5,
                ),
          Text(
            title,
            style: titleStyle ??
                semibold12.copyWith(color: cleanerColor.primary10),
          ),
        ],
      ),
    );
  }
}
