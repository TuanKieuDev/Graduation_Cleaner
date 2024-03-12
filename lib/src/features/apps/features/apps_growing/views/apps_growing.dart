import 'package:phone_cleaner/router/router.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:phone_cleaner/src/features/features.dart';
import 'package:phone_cleaner/src/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppsGrowing extends ConsumerStatefulWidget {
  const AppsGrowing({super.key, required this.padding});

  final EdgeInsets padding;

  @override
  ConsumerState<AppsGrowing> createState() => _AppsGrowingState();
}

class _AppsGrowingState extends ConsumerState<AppsGrowing> {
  @override
  Widget build(BuildContext context) {
    final appsGrowingController = ref.watch(appsGrowingControllerProvider);
    if (appsGrowingController.hasError) {
      return const SizedBox.shrink();
    }
    final dataGrowing = appsGrowingController.requireValue;

    final cleanerColor = CleanerColor.of(context)!;

    Future<void> showInfoiDialog() async {
      return showDialog<void>(
          context: context,
          builder: (context) {
            return NoteDialog(
              title: 'About growing',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "The 3 most prominent applications that have had the largest growth in occupied storage over the past seven days are listed. Press to view the complete catalogue.",
                    style: regular14.copyWith(color: cleanerColor.neutral5),
                  )
                ],
              ),
            );
          });
    }

    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Growing",
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
          ),
          _GrowingDetail(
            appsGrowing: dataGrowing,
          )
        ],
      ),
    );
  }
}

class _GrowingDetail extends ConsumerWidget {
  const _GrowingDetail({
    required this.appsGrowing,
  });

  final AppsGrowingInfo appsGrowing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRemaining =
        ref.watch(appsGrowingControllerProvider).value?.timeForAnalysis ?? 0;
    final cleanerColor = CleanerColor.of(context)!;
    if (timeRemaining > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
        child: Column(
          children: [
            Text(
              "You will be able to use this feature when we are done with the analysis",
              textAlign: TextAlign.center,
              style: regular12.copyWith(color: cleanerColor.neutral5),
            ),
            const SizedBox(
              height: 8,
            ),
            TimeRemaining(timeRemaining: timeRemaining),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            "Change last 7 days",
            style: regular14.copyWith(
              color: cleanerColor.neutral1,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            GoRouter.of(context).pushNamed(AppRouter.listApp,
                extra: const AppFilterArguments(
                  appFilterParameter: AppFilterParameter(
                    sortType: SortType.sizeChange,
                  ),
                ));
          },
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GrowingApp(
                size: appsGrowing.growingData[1].sizeChange,
                iconData: appsGrowing.growingData[1].iconData!,
              ),
              GrowingApp(
                size: appsGrowing.growingData[0].sizeChange,
                iconData: appsGrowing.growingData[0].iconData!,
                isCenter: true,
              ),
              GrowingApp(
                size: appsGrowing.growingData[2].sizeChange,
                iconData: appsGrowing.growingData[2].iconData!,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
