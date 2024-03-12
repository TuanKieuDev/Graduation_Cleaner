import 'package:app_settings/app_settings.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/commons/widgets/file_checkbox_item.dart';
import 'package:phone_cleaner/src/features/apps/features/notification/controller/notification_usage_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../router/router.dart';
import '../../../../../themes/themes.dart';
import '../../../apps.dart';
import '../../apps_usage/views/bar_chart.dart';

class NotificationPart extends ConsumerStatefulWidget {
  const NotificationPart({super.key});

  @override
  ConsumerState<NotificationPart> createState() => _NotificationPartState();
}

class _NotificationPartState extends ConsumerState<NotificationPart>
    with WidgetsBindingObserver {
  late bool isNotificationAccessGranted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await checkReadNotificationPermissionCallback();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> checkReadNotificationPermissionCallback() async {
    final result = await AppSettings.checkNotificationListenerPermissions();
    if (!mounted) return;
    setState(() {
      isNotificationAccessGranted = result;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkReadNotificationPermissionCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    Future<void> showInfoiDialog() async {
      return showDialog<void>(
          context: context,
          builder: (context) {
            return NoteDialog(
              title: 'About notification',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "The graph depicts the overall quantity of notifications received in the past seven days, beginning from the point when access was authorized. Press it to view the statistics divided by individual applications.",
                    style: regular14.copyWith(color: cleanerColor.neutral5),
                  )
                ],
              ),
            );
          });
    }

    Widget label = Row(
      children: [
        Text(
          "Notification",
          style: bold20.copyWith(color: cleanerColor.primary10),
        ),
        TextButton(
          onPressed: () {
            showInfoiDialog();
          },
          child: const Icon(
            Icons.info_outline,
            size: 20,
            color: Color.fromRGBO(51, 167, 82, 1),
          ),
        ),
      ],
    );

    if (!isNotificationAccessGranted) {
      return _GrantAccessWidget(
        label: label,
      );
    }

    final data = ref.watch(notificationUsageControllerProvider);
    if (data.hasError) {
      return const ErrorPage();
    }
    if (data.isLoading) {
      return const CircularProgressIndicator();
    }

    final notificationUsageData = data.requireValue;
    final notificationData = notificationUsageData.dataWithNotificationWeekly;
    final totalNotification = notificationUsageData.totalNotificationWeekly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 24),
          child: Text(
            "Change last 7 days",
            style: regular14.copyWith(
              color: cleanerColor.neutral1,
            ),
          ),
        ),
        BarChartUsage(
          barChartData: notificationUsageData.barChartData!,
          isNotification: true,
        ),
        const SizedBox(
          height: 16,
        ),
        _IconAndNotifications(
          notificationData: notificationData.take(3).toList(),
          totalNotification: totalNotification,
        ),
      ],
    );
  }
}

class _GrantAccessWidget extends StatelessWidget {
  const _GrantAccessWidget({required this.label});
  final Widget label;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;

    return Column(
      children: [
        label,
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                "Notification access is required to display the the app that sends you the most notifications",
                style: regular12.copyWith(color: cleanerColor.neutral5),
                textAlign: TextAlign.center,
              ),
            ),
            PrimaryButton(
              title: Row(
                children: const [
                  Icon(Icons.lock),
                  SizedBox(
                    width: 14,
                  ),
                  Text("Grant access"),
                ],
              ),
              onPressed: () {
                AppSettings.openNotificationSettings();
              },
              width: double.maxFinite,
              borderRadius: BorderRadius.circular(16),
            )
          ],
        ),
      ],
    );
  }
}

class _IconAndNotifications extends StatelessWidget {
  const _IconAndNotifications({
    required this.notificationData,
    required this.totalNotification,
  });

  final List<AppCheckboxItemData> notificationData;
  final int totalNotification;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return TextButton(
      onPressed: () {
        GoRouter.of(context).pushNamed(AppRouter.listApp,
            extra: const AppFilterArguments(
              appFilterParameter: AppFilterParameter(
                sortType: SortType.notification,
              ),
            ));
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
      ),
      child: Row(
        children: [
          for (int i = 0; i < notificationData.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: cleanerColor.neutral3,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: cleanerColor.neutral4.withOpacity(0.5),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: AppIcon(
                  packageName: notificationData[i].packageName,
                  size: 40,
                ),
              ),
            ),
          SizedBox(
              width: 40,
              height: 40,
              child: SvgPicture.asset('assets/icons/ic_apps/3dots.svg')),
          const SizedBox(
            width: 14,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$totalNotification",
                    style: bold20.copyWith(color: cleanerColor.primary10),
                  ),
                  Text(
                    totalNotification > 1 ? 'Notifications' : 'Notification',
                    style: TextStyle(color: cleanerColor.neutral5),
                  ),
                ],
              ),
              Icon(
                Icons.navigate_next,
                color: cleanerColor.primary7,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
