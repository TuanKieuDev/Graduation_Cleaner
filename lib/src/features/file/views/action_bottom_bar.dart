// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';

import '../../../commons/widgets/action_bottom_bar.dart';
import '../../../themes/themes.dart';

class FileBottomBar extends ConsumerWidget {
  const FileBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(fileFilterControllerProvider
        .select((value) => value.valueOrNull?.checkedCheckboxItems));
    if (selected == null) {
      return const SizedBox.shrink();
    }

    Future<void> showDeleteDialog() async {
      final cleanerColor = CleanerColor.of(context)!;

      var cancelButton = PrimaryButton(
          title: Text('Cancel',
              style: regular14.copyWith(color: cleanerColor.primary7)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          height: 32,
          enableShadow: false,
          width: (MediaQuery.of(context).size.width - 120) / 2,
          borderRadius: BorderRadius.circular(16),
          gradientColor: LinearGradient(colors: [
            cleanerColor.primary1,
            cleanerColor.primary1,
          ]));
      var deleteButton = PrimaryButton(
        title: Text(
          'Delete',
          style: regular14.copyWith(color: cleanerColor.neutral3),
        ),
        onPressed: () {
          ref.read(fileFilterControllerProvider.notifier).deleteFiles(selected);
          Navigator.of(context).pop();
        },
        height: 32,
        enableShadow: false,
        width: (MediaQuery.of(context).size.width - 120) / 2,
        borderRadius: BorderRadius.circular(16),
        gradientColor: cleanerColor.gradient4,
      );

      return showDialog<void>(
          context: context,
          builder: (context) {
            return CleanerDialog(
                lottiePath: 'assets/lotties/delete_effect.json',
                title: '',
                content:
                    "Are you sure you want to delete? Deleted files cannot be recovered.",
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      cancelButton,
                      deleteButton,
                    ],
                  ),
                ]);
          });
    }

    final checkedSize = selected.fold(
        0.kb, (previousValue, element) => previousValue + element.size);
    final selectedPhotos = selected
        .where((element) => element.fileType == FileType.photo)
        .toList();
    return ActionBottomBar(
      selectedCount: selected.length,
      checkedSize: checkedSize,
      actions: [
        ActionButton(
            icon: const CleanerIcon(icon: CleanerIcons.navShare),
            title: 'Share',
            onPressed: () =>
                Share.shareXFiles(selected.map((e) => XFile(e.path)).toList())),
        ActionButton(
            icon: const CleanerIcon(icon: CleanerIcons.navOptimize),
            title: "Optimize",
            isEnable: selectedPhotos.isNotEmpty,
            onPressed: () => GoRouter.of(context).pushNamed(
                AppRouter.photoOptimizer,
                extra: selectedPhotos,
                params: {"totalSize": checkedSize.toStringOptimal()})),
        // ActionButton(
        //     icon: const CleanerIcon(icon: CleanerIcons.navBackup),
        //     title: "Backup",
        //     onPressed: () =>
        //         GoRouter.of(context).pushNamed(AppRouter.toBeUpdated)),
        ActionButton(
            icon: const CleanerIcon(icon: CleanerIcons.navUninstall),
            title: 'Delete',
            onPressed: () => showDeleteDialog()),
      ],
    );
  }
}
