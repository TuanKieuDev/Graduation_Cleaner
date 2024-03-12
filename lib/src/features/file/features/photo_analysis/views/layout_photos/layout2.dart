import 'package:flutter/material.dart';

import '../../../../../../commons/models/file_checkbox_item_data.dart';
import '../../../../views/image_card.dart';

class Layout2 extends StatelessWidget {
  const Layout2({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<FileCheckboxItemData> data;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ImageCard(
              width: constraints.maxWidth - 10,
              height: (constraints.maxWidth - 10) * 1 / 2,
              source: data[0].path,
            ),
            ImageCard(
              width: constraints.maxWidth - 10,
              height: (constraints.maxWidth - 10) * 1 / 2,
              source: data[1].path,
            ),
          ],
        );
      },
    );
  }
}
