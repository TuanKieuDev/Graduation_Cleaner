import 'package:flutter/material.dart';

import '../../themes/themes.dart';
import '../commons.dart';

const double _iconPaddingRight = 4;

class FilterButton extends StatelessWidget {
  const FilterButton({
    Key? key,
    required this.filterLabel,
  }) : super(key: key);

  final String filterLabel;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Align(
      alignment: Alignment.centerLeft,
      child: LayoutBuilder(builder: (context, constraint) {
        return Container(
          // constraints: const BoxConstraints(maxHeight: 35),
          // height: 35,
          decoration: BoxDecoration(
            color: cleanerColor.primary2,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextButton(
            onPressed: () {
              Future.delayed(
                buttonTransitionDuration,
                () => Scaffold.of(context).openEndDrawer(),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: CleanerIcon(
                      icon: CleanerIcons.filter,
                      color: cleanerColor.primary10,
                    ),
                  ),
                  const SizedBox(width: _iconPaddingRight),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: constraint.maxWidth - 60,
                    ),
                    child: Text(
                      filterLabel,
                      maxLines: 2,
                      softWrap: true,
                      style: regular12.copyWith(
                        color: cleanerColor.primary10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
