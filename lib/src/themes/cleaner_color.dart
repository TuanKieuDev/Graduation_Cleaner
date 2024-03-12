import 'package:flutter/material.dart';

@immutable
class CleanerColor extends ThemeExtension<CleanerColor> {
  static CleanerColor? of(context) =>
      Theme.of(context).extension<CleanerColor>();

  const CleanerColor({
    required this.primary1,
    required this.primary2,
    required this.primary3,
    required this.primary4,
    required this.primary5,
    required this.primary6,
    required this.primary7,
    required this.primary8,
    required this.primary9,
    required this.primary10,
    required this.neutral1,
    required this.neutral3,
    required this.neutral2,
    required this.neutral4,
    required this.neutral5,
    required this.gradient1,
    required this.gradient2,
    required this.gradient3,
    required this.gradient4,
    required this.gradient5,
    required this.textDisable,
    required this.btnDisable,
    required this.selectedColor,
  });

  final Color primary1;
  final Color primary2;
  final Color primary3;
  final Color primary4;
  final Color primary5;
  final Color primary6;
  final Color primary7;
  final Color primary8;
  final Color primary9;
  final Color primary10;

  final Color neutral1;
  final Color neutral3;
  final Color neutral2;
  final Color neutral4;
  final Color neutral5;

  final Gradient gradient1;
  final Gradient gradient2;
  final Gradient gradient3;
  final Gradient gradient4;
  final Gradient gradient5;
  final Color textDisable;
  final Color btnDisable;

  final Color selectedColor;

  @override
  ThemeExtension<CleanerColor> lerp(
      ThemeExtension<CleanerColor>? other, double t) {
    if (other is! CleanerColor) {
      return this;
    }
    return CleanerColor(
      primary1: Color.lerp(primary1, other.primary1, t)!,
      primary2: Color.lerp(primary2, other.primary2, t)!,
      primary3: Color.lerp(primary3, other.primary3, t)!,
      primary4: Color.lerp(primary4, other.primary4, t)!,
      primary5: Color.lerp(primary5, other.primary5, t)!,
      primary6: Color.lerp(primary6, other.primary6, t)!,
      primary7: Color.lerp(primary7, other.primary7, t)!,
      primary8: Color.lerp(primary8, other.primary8, t)!,
      primary9: Color.lerp(primary9, other.primary9, t)!,
      primary10: Color.lerp(primary10, other.primary10, t)!,
      neutral1: Color.lerp(neutral1, other.neutral1, t)!,
      neutral3: Color.lerp(neutral3, other.neutral3, t)!,
      neutral2: Color.lerp(neutral2, other.neutral2, t)!,
      neutral4: Color.lerp(neutral4, other.neutral4, t)!,
      neutral5: Color.lerp(neutral4, other.neutral4, t)!,
      gradient1: Gradient.lerp(gradient1, other.gradient1, t)!,
      gradient2: Gradient.lerp(gradient2, other.gradient2, t)!,
      gradient3: Gradient.lerp(gradient3, other.gradient3, t)!,
      gradient4: Gradient.lerp(gradient4, other.gradient4, t)!,
      gradient5: Gradient.lerp(gradient5, other.gradient5, t)!,
      textDisable: Color.lerp(textDisable, other.textDisable, t)!,
      btnDisable: Color.lerp(btnDisable, other.btnDisable, t)!,
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t)!,
    );
  }

  @override
  CleanerColor copyWith({
    Color? primary1,
    Color? primary2,
    Color? primary3,
    Color? primary4,
    Color? primary5,
    Color? primary6,
    Color? primary7,
    Color? primary8,
    Color? primary9,
    Color? primary10,
    Color? neutral1,
    Color? neutral3,
    Color? neutral2,
    Color? neutral4,
    Color? neutral5,
    Gradient? gradient1,
    Gradient? gradient2,
    Gradient? gradient3,
    Gradient? gradient4,
    Gradient? gradient5,
    Color? textDisable,
    Color? btnDisable,
    Color? selectedColor,
  }) {
    return CleanerColor(
      primary1: primary1 ?? this.primary1,
      primary2: primary2 ?? this.primary2,
      primary3: primary3 ?? this.primary3,
      primary4: primary4 ?? this.primary4,
      primary5: primary5 ?? this.primary5,
      primary6: primary6 ?? this.primary6,
      primary7: primary7 ?? this.primary7,
      primary8: primary8 ?? this.primary8,
      primary9: primary9 ?? this.primary9,
      primary10: primary10 ?? this.primary10,
      neutral1: neutral1 ?? this.neutral1,
      neutral3: neutral3 ?? this.neutral3,
      neutral2: neutral2 ?? this.neutral2,
      neutral4: neutral4 ?? this.neutral4,
      neutral5: neutral5 ?? this.neutral5,
      gradient1: gradient1 ?? this.gradient1,
      gradient2: gradient2 ?? this.gradient2,
      gradient3: gradient3 ?? this.gradient3,
      gradient4: gradient4 ?? this.gradient4,
      gradient5: gradient5 ?? this.gradient5,
      textDisable: textDisable ?? this.textDisable,
      btnDisable: btnDisable ?? this.btnDisable,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  @override
  String toString() {
    return 'CleanerColor(primary1: $primary1, primary2: $primary2, primary3: $primary3, primary4: $primary4, primary5: $primary5, primary6: $primary6, primary7: $primary7, primary8: $primary8, primary9: $primary9, primary10: $primary10, neutral1: $neutral1, neutral3: $neutral3, neutral2: $neutral2, neutral4: $neutral4, neutral5: $neutral5, gradient1: $gradient1, gradient2: $gradient2, gradient3: $gradient3, gradient4: $gradient4, gradient5: $gradient5, selectedColor: $selectedColor)';
  }
}
