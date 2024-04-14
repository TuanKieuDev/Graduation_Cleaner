import 'package:phone_cleaner/di/injector.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/services/preference_services/shared_preferences_manager.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:monetization/monetization.dart';

import '../../../../router/router.dart';
import '../../../themes/themes.dart';

class AccessRightsPage extends StatelessWidget {
  const AccessRightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Scaffold(
      backgroundColor: cleanerColor.neutral3,
      body: Stack(
        children: [
          const Background(
            secondaryBackground: true,
          ),
          SafeArea(
            child: Column(
              children: const [
                SecondaryAppBar(title: 'Access rights'),
                _Content(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends ConsumerStatefulWidget {
  const _Content();

  @override
  ConsumerState<_Content> createState() => _ContentState();
}

class _ContentState extends ConsumerState<_Content>
    with WidgetsBindingObserver {
  PermissionController get permissionController =>
      ref.watch(permissionControllerProvider.notifier);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      permissionController.build();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      permissionController.checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    ref.watch(permissionControllerProvider);
    var isAllGranted =
        ref.watch(permissionControllerProvider).value?.isAllGranted ?? false;
    var isFileGranted =
        ref.watch(permissionControllerProvider).value?.isFileGranted ?? false;
    var isUsageGranted =
        ref.watch(permissionControllerProvider).value?.isUsageGranted ?? false;

    appLogger.debug(
        'isFileGranted: $isFileGranted && isUsageGranted: $isUsageGranted');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: SvgPicture.asset('assets/images/lock_logo.svg'),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Allow access',
              style: semibold16.copyWith(color: cleanerColor.primary10),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          _RequestTile(
            label: "To manage all files",
            isGranted: isFileGranted,
          ),
          _RequestTile(
            label: "Usage data",
            isGranted: isUsageGranted,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Text(
              "We need access to clean up your medias \n and provide better insights for your applications.",
              style: regular12.copyWith(
                color: cleanerColor.neutral5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          PrimaryButton(
            onPressed: () async {
              if (isAllGranted) {

                final goRouter = GoRouter.of(context);
                goRouter.goNamed(AppRouter.home);
                goRouter.pushNamed(AppRouter.quickClean);

                injector.get<SharedPreferencesManager>().saveFirstLaunch(false);
              } else {
                await permissionController.requestStoragePermission();
                await permissionController.requestUsagePermission();
              }
            },
            width: double.maxFinite,
            borderRadius: BorderRadius.circular(16),
            title: AnimatedCrossFade(
              duration: const Duration(seconds: 1),
              firstCurve: Curves.easeOutBack,
              secondCurve: Curves.easeInBack,
              firstChild: const _SettingButton(),
              secondChild: const _ScanButton(),
              crossFadeState: !isAllGranted
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingButton extends StatelessWidget {
  const _SettingButton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CleanerIcon(
          icon: CleanerIcons.setting,
          color: Colors.white,
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          "Go to settings",
          style: bold18,
        )
      ],
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CleanerIcon(
          icon: CleanerIcons.cleaner,
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          "Scan to clean",
          style: bold18,
        )
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.label,
    required this.isGranted,
  });

  final String label;
  final bool isGranted;

  @override
  Widget build(BuildContext context) {
    final cleanerColor = CleanerColor.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          isGranted
              ? SvgPicture.asset('assets/icons/ic_verify.svg')
              : SvgPicture.asset('assets/icons/ic_request.svg'),
          const SizedBox(
            width: 8,
          ),
          Text(
            label,
            style: TextStyle(
              color: cleanerColor.primary10,
            ),
          ),
        ],
      ),
    );
  }
}
