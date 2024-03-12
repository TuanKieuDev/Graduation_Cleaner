import 'package:phone_cleaner/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../commons/commons.dart';

Future<void> showRequestManageFileDialog(
    BuildContext context, WidgetRef ref) async {
  const lottiePath = 'assets/lotties/lock_effect.json';

  return showDialog<void>(
      context: context,
      builder: (context) {
        var actionGrantAccess = Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 30),
          child: PrimaryButton(
            onPressed: () {
              ref
                  .read(permissionControllerProvider.notifier)
                  .requestStoragePermission();

              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(16),
            title: const Text('Grant access'),
            width: double.maxFinite,
            height: 40,
          ),
        );
        return CleanerDialog(
          lottiePath: lottiePath,
          title: "Grant access permissions",
          content:
              "Cleaner không thể hoạt động mà không có quyền truy cập vào bộ nhớ của bạn. Vui lòng cấp quyền truy cập",
          actions: [
            actionGrantAccess,
          ],
        );
      });
}

Future<void> showRequestAccessUsageDialog(
    BuildContext context, WidgetRef ref) async {
  const lottiePath = 'assets/lotties/lock_effect.json';

  return showDialog<void>(
      context: context,
      builder: (context) {
        var actions = [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 30),
            child: PrimaryButton(
              onPressed: () {
                ref
                    .read(permissionControllerProvider.notifier)
                    .requestUsagePermission();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(16),
              title: const Text('Grant access'),
              width: double.maxFinite,
              height: 40,
            ),
          )
        ];
        return CleanerDialog(
          lottiePath: lottiePath,
          title: "Grant access permissions",
          content:
              'Cleaner không thể hoạt động mà không có quyền truy cập thông tin sử dụng ứng dụng của bạn. Vui lòng cấp quyền truy cập',
          actions: actions,
        );
      });
}
