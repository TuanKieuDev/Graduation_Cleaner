import 'package:phone_cleaner/di/injector.dart';
import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/router/app_observers.dart';
import 'package:phone_cleaner/services/firebase_analytic/firebase_analytic_service.dart';
import 'package:phone_cleaner/src/commons/pages/detail_page.dart';
import 'package:phone_cleaner/src/commons/widgets/result_detail.dart';
import 'package:phone_cleaner/src/features/ads/ads_route_pop_observer.dart';
import 'package:phone_cleaner/src/features/file/features/filter/views/file_filter_page.dart';
import 'package:phone_cleaner/src/features/file/features/photo_optimizer/views/photo_optimizer_detail.dart';
import 'package:phone_cleaner/src/features/file/features/photo_optimizer/views/preview_photo_page.dart';
import 'package:phone_cleaner/src/features/introduction/introduction.dart';
import 'package:go_router/go_router.dart';
import '../src/commons/commons.dart';
import '../src/features/features.dart';
import '../src/features/quick_boost/src/views/boost_loading.dart';
import '/router/transition_builder.dart';
import '/router/transition_type.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String cleanerOverview = "/cleaner_overview";
  static const String accessRights = "/access_rights";
  static const String quickClean = '/quick_clean';
  static const String toBeUpdated = '/to_be_updated';
  static const String file = '/file';
  static const String fileFilter = '/file_filter';
  static const String media = '/media';
  static const String boost = '/boost';
  static const String apps = '/apps';
  static const String listApp = '/list_app';
  static const String appDetail = '/app_detail';
  static const String battery = '/battery';
  static const String upgrade = '/upgrade';
  static const String cloudService = '/cloud_service';
  static const String systemInformation = '/system_information';
  static const String savingTips = '/saving_tips';
  static const String securityTips = '/security_tips';
  static const String helpAndFeedback = '/help_and_feedback';
  static const String aboutApp = '/about_app';
  static const String notification = '/notification';
  static const String privacy = '/privacy';
  static const String boostLoading = '/boost_loading';
  static const String boostResult = '/boost_result';
  static const String cleanResult = '/clean_result';
  static const String photoOptimizer = '/photo_optimizer/:totalSize';
  static const String previewPhoto = '/preview_photo';
  static const String photoDetail = '/photo_detail';
  static const String detailInformation = '/detail_information';
  static const String error = '/error';
  static const String result = '/result';
  static const String resultDetail = '/result_detail';
  static const String uninstallApp = '/uninstall_app';

  static GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    observers: [
      injector.get<FirebaseAnalyticService>().getAnalyticsObserver(),
      AppObservers(),
      AdsRoutePopObserver()
    ],
    routes: [
      GoRoute(
        name: splash,
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        name: home,
        path: home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: cleanerOverview,
        path: cleanerOverview,
        builder: (context, state) => const CleanerOverview(),
      ),
      GoRoute(
        name: accessRights,
        path: accessRights,
        builder: (context, state) => const AccessRightsPage(),
      ),
      GoRoute(
        name: quickClean,
        path: quickClean,
        builder: (context, state) => const QuickClean(),
      ),
      GoRoute(
        name: media,
        path: media,
        builder: (context, state) => const FilePage(),
      ),
      GoRoute(
        name: boost,
        path: boost,
        builder: (context, state) => const QuickBoost(),
      ),
      GoRoute(
        name: apps,
        path: apps,
        builder: (context, state) => const AppsPage(),
      ),
      GoRoute(
        name: battery,
        path: battery,
        builder: (context, state) => const BatteryBoost(),
      ),
      GoRoute(
        name: upgrade,
        path: upgrade,
        builder: (context, state) => const ToBeUpdatedPage(pageName: upgrade),
      ),
      GoRoute(
        name: cloudService,
        path: cloudService,
        builder: (context, state) =>
            const ToBeUpdatedPage(pageName: cloudService),
      ),
      GoRoute(
        name: systemInformation,
        path: systemInformation,
        builder: (context, state) =>
            const ToBeUpdatedPage(pageName: systemInformation),
      ),
      GoRoute(
        name: savingTips,
        path: savingTips,
        builder: (context, state) => const SavingTipsView(),
      ),
      GoRoute(
        name: securityTips,
        path: securityTips,
        builder: (context, state) =>
            const ToBeUpdatedPage(pageName: securityTips),
      ),
      GoRoute(
        name: helpAndFeedback,
        path: helpAndFeedback,
        builder: (context, state) =>
            const ToBeUpdatedPage(pageName: helpAndFeedback),
      ),
      GoRoute(
        name: aboutApp,
        path: aboutApp,
        builder: (context, state) => const ToBeUpdatedPage(pageName: aboutApp),
      ),
      GoRoute(
        name: notification,
        path: notification,
        builder: (context, state) =>
            const ToBeUpdatedPage(pageName: notification),
      ),
      GoRoute(
        name: privacy,
        path: privacy,
        builder: (context, state) => const ToBeUpdatedPage(pageName: privacy),
      ),
      GoRoute(
          name: fileFilter,
          path: fileFilter,
          builder: (context, state) {
            final args = state.extra as FileFilterArguments;
            return FileFilterPage(
              arguments: args,
            );
          }),
      GoRoute(
          name: photoOptimizer,
          path: photoOptimizer,
          builder: (context, state) {
            return const PhotoOptimizerScreen();
          }),
      GoRoute(
          name: previewPhoto,
          path: previewPhoto,
          builder: (context, state) {
            // final optimizationResult = state.extra as PreviewPhotoArguments;
            return const OptimizerPreviewPhotoPage();
          }),
      GoRoute(
          name: photoDetail,
          path: photoDetail,
          builder: (context, state) {
            final photoData = state.extra as PhotoDetailArgument;
            return PhotoDetail(
              data: photoData,
            );
          }),
      GoRoute(
          name: detailInformation,
          path: detailInformation,
          builder: (context, state) {
            final detailArgs = state.extra as DetailPageArgs;
            return DetailPage(
              args: detailArgs,
            );
          }),
      GoRoute(
        name: boostLoading,
        path: boostLoading,
        builder: (context, state) => const BoostLoading(),
      ),
      GoRoute(
        name: boostResult,
        path: boostResult,
        builder: (context, state) => const BoostResult(),
      ),
      GoRoute(
        name: cleanResult,
        path: cleanResult,
        builder: (context, state) => const CleanResult(),
      ),
      GoRoute(
        name: listApp,
        path: listApp,
        builder: (context, state) {
          final args = state.extra as AppFilterArguments;
          return AppFilterPage(args: args);
        },
      ),
      GoRoute(
        name: appDetail,
        path: appDetail,
        builder: (context, state) {
          final index = state.extra as int;

          return AppDetail(
            index: index,
          );
        },
      ),
      GoRoute(
        name: toBeUpdated,
        path: toBeUpdated,
        pageBuilder: (context, state) => buildPageWithTransition(
            transitionType: TransitionType.fade,
            transitionDuration: 500,
            context: context,
            state: state,
            // ignore: deprecated_member_use_from_same_package
            child: const ToBeUpdatedPage(pageName: toBeUpdated)),
      ),
      GoRoute(
        name: error,
        path: error,
        pageBuilder: (context, state) {
          final cleanerException = state.extra as CleanerException;
          return buildPageWithTransition(
              transitionType: TransitionType.fade,
              transitionDuration: 500,
              context: context,
              state: state,
              child: ErrorPage.fromCleanerException(cleanerException));
        },
      ),
      GoRoute(
        name: result,
        path: result,
        builder: (context, state) {
          final args = state.extra as ResultArgs;
          return Result(
            title: args.title,
            savedValue: args.savedValue,
            successResults: args.successResults,
            failedResults: args.failedResults,
          );
        },
      ),
      GoRoute(
        name: resultDetail,
        path: resultDetail,
        builder: (context, state) {
          final args = state.extra as ResultDetailArgs;
          return ResultDetail(
            title: args.title,
            results: args.results,
          );
        },
      ),
      GoRoute(
        name: uninstallApp,
        path: uninstallApp,
        builder: (context, state) {
          final args = state.extra as UninstallAppArguments;
          return UninstallAppView(
            uninstallAppArguments: args,
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      return const ErrorPage();
    },
  );
}
