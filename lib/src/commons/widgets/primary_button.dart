import 'package:flutter/material.dart';

import '../../themes/themes.dart';

class PrimaryButton extends StatelessWidget {
  final Widget title;
  final bool enable;
  final bool enableShadow;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Gradient gradientColor;
  final TextStyle? textStyle;
  const PrimaryButton({
    Key? key,
    required this.title,
    this.enable = true,
    this.enableShadow = true,
    required this.onPressed,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
    this.gradientColor = const LinearGradient(
      colors: [Color(0xFF3258F3), Color(0xFF2DA6FF)],
      stops: [2.38 / 100, 102.38 / 100],
      begin: Alignment(1, 1),
      end: Alignment(-1, -1),
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Container(
      width: width ?? 160,
      height: height ?? 46,
      decoration: BoxDecoration(
        color: enable
            ? CleanerColor.of(context)!.neutral3
            : CleanerColor.of(context)!.neutral4,
        gradient: enable ? gradientColor : null,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        boxShadow: enable && enableShadow
            ? const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  offset: Offset(5, 5),
                  blurRadius: 10,
                )
              ]
            : const [],
      ),
      child: TextButton(
        onPressed: enable ? onPressed : null,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: cleanerColor.neutral3,
          textStyle: textStyle ?? semibold16,
        ),
        child: FittedBox(child: title),
      ),
    );
  }
}
