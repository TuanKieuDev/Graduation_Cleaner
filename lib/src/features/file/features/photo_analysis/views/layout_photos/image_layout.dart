import 'package:phone_cleaner/src/commons/models/file_checkbox_item_data.dart';
import 'package:flutter/material.dart';

import 'views.dart';

class ImageLayout extends StatelessWidget {
  const ImageLayout({
    super.key,
    required this.length,
    required this.data,
  });

  final int length;
  final List<FileCheckboxItemData> data;

  @override
  Widget build(BuildContext context) {
    switch (length) {
      case 0:
      case 1:
        return Layout1(data: data);
      case 2:
        return Layout2(data: data);
      case 3:
        return Layout3(data: data);
      case 4:
        return Layout4(data: data);
      default:
        return Layout5(data: data);
    }
  }
}
