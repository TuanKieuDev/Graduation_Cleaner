import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';

class AllButton extends StatelessWidget {
  const AllButton({
    Key? key,
    required this.onPress,
  }) : super(key: key);

  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPress,
        splashColor: cleanerColor.primary3,
        highlightColor: cleanerColor.primary2,
        child: Row(
          children: [
            Text("All",
                style: semibold18.copyWith(color: cleanerColor.primary6)),
            Icon(
              Icons.navigate_next,
              color: cleanerColor.primary6,
            )
          ],
        ),
      ),
    );
  }
}
