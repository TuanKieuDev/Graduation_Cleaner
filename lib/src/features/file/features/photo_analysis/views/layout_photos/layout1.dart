import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../commons/models/file_checkbox_item_data.dart';
import '../../../../views/image_card.dart';

class Layout1 extends StatelessWidget {
  const Layout1({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<FileCheckboxItemData> data;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return data.isNotEmpty
            ? ImageCard(
                width: constraints.maxWidth - 10,
                height: constraints.maxWidth - 10,
                source: data[0].path,
              )
            : SizedBox(
                width: constraints.maxWidth - 10,
                height: constraints.maxWidth - 10,
                child: SvgPicture.asset('assets/images/place_holder_image.svg'),
              );
      },
    );
  }
}
