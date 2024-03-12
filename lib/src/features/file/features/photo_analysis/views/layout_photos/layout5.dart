import 'package:flutter/material.dart';

import '../../../../../../commons/models/file_checkbox_item_data.dart';
import '../../../../views/image_card.dart';

class Layout5 extends StatelessWidget {
  const Layout5({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<FileCheckboxItemData> data;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ImageCard(
                  width: (constraints.maxWidth - 10) * 2 / 3,
                  height: (constraints.maxWidth - 10) * 1 / 2,
                  source: data[0].path,
                ),
                ImageCard(
                  width: (constraints.maxWidth - 10) * 2 / 3,
                  height: (constraints.maxWidth - 10) * 1 / 2,
                  source: data[1].path,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ImageCard(
                  width: (constraints.maxWidth - 10) * 1 / 3,
                  height: (constraints.maxWidth - 10) * 1 / 3,
                  source: data[2].path,
                ),
                ImageCard(
                  width: (constraints.maxWidth - 10) * 1 / 3,
                  height: (constraints.maxWidth - 10) * 1 / 3,
                  source: data[3].path,
                ),
                ImageCard(
                  width: (constraints.maxWidth - 15) * 1 / 3,
                  height: (constraints.maxWidth - 15) * 1 / 3,
                  source: data[4].path,
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
