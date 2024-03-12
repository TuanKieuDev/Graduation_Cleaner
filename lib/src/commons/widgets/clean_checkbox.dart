import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';

enum CheckboxStatus {
  unchecked,
  partiallyChecked,
  checked,
}

class CleanCheckbox extends StatelessWidget {
  const CleanCheckbox({
    required this.onChanged,
    this.checkboxStatus = CheckboxStatus.unchecked,
    this.scale = 1,
    super.key,
  });

  final CheckboxStatus checkboxStatus;
  final double scale;
  final ValueChanged<CheckboxStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 19,
        height: 19,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: cleanerColor.neutral4,
        ),
        child: Checkbox(
          value: checkboxStatus.toValue(),
          tristate: true,
          side: BorderSide.none,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          activeColor: cleanerColor.selectedColor,
          onChanged: (value) => onChanged(value.toCheckboxStatus()),
        ),
      ),
    );
  }
}

extension on bool? {
  CheckboxStatus toCheckboxStatus() {
    if (this == null) {
      return CheckboxStatus.partiallyChecked;
    } else if (this!) {
      return CheckboxStatus.checked;
    } else if (!this!) {
      return CheckboxStatus.unchecked;
    }

    throw UnimplementedError();
  }
}

extension on CheckboxStatus {
  bool? toValue() {
    switch (this) {
      case CheckboxStatus.unchecked:
        return false;
      case CheckboxStatus.partiallyChecked:
        return null;
      case CheckboxStatus.checked:
        return true;
    }
  }
}
