import 'package:phone_cleaner/src/commons/widgets/cleaner_icon.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';

// ! reference = 0
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leadingWidth: 0,
      title: Text(
        'Cleaner',
        textAlign: TextAlign.center,
        style: bold24.copyWith(color: CleanerColor.of(context)!.primary5),
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: CleanerColor.of(context)!.neutral3,
              boxShadow: const [
                BoxShadow(
                    offset: Offset(2, 2),
                    blurRadius: 8,
                    color: Color.fromRGBO(66, 133, 244, 0.2))
              ]),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: CleanerIcons.menu.toWidget(fit: BoxFit.scaleDown),
              ),
              IconButton(
                icon: CleanerIcons.setting.toWidget(),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
