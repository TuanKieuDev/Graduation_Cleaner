import 'package:phone_cleaner/src/features/file/file.dart';
import 'package:flutter/material.dart';

class GroupLayout extends StatelessWidget {
  const GroupLayout({
    super.key,
    required this.displayGrid,
    required this.groupData,
  });

  final bool displayGrid;
  final List<FileCategory> groupData;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        for (int i = 0; i < groupData.length; i++)
          FileCategoryItem(
            categoryIndex: i,
            displayGrid: displayGrid,
          ),
      ],
    );
  }
}
