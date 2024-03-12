import 'dart:math';

import 'package:flutter/material.dart';

class ExpandButton extends StatelessWidget {
  const ExpandButton({
    required this.valueChanged,
    required this.isExpanded,
    super.key,
  });

  final bool isExpanded;
  final ValueSetter<bool> valueChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => valueChanged(!isExpanded),
      icon: Transform.rotate(
        angle: isExpanded ? 180 * pi / 180 : pi / 180,
        child: const Icon(
          Icons.expand_more,
          color: Color.fromRGBO(66, 149, 255, 1),
        ),
      ),
    );
  }
}
