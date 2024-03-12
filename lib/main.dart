import 'dart:async';
import 'dart:isolate';

import 'package:phone_cleaner/di/app_modules.dart';
import 'package:phone_cleaner/di/injector.dart';
import 'package:phone_cleaner/gen/firebase_options.dart';
import 'package:phone_cleaner/services/logger/logger.dart';
import 'package:phone_cleaner/services/notifications/notification_services.dart';
import 'package:phone_cleaner/services/work_manager/work_manager_services.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monetization/monetization.dart';

import 'router/router.dart';
import 'src/features/home/src/features/permission/permission.dart';
import 'src/themes/themes.dart';

void main() async {
  Future<void> startApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      SkynetMonetization.instance.init();
    } on Exception catch (e, stacktrace) {
      appLogger.error('AdManager initialization error', e, stacktrace);
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (errorDetails) {
      // If you wish to record a "non-fatal" exception, please use `FirebaseCrashlytics.instance.recordFlutterError` instead
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      // If you wish to record a "non-fatal" exception, please remove the "fatal" parameter
      FirebaseCrashlytics.instance.recordError(error, stack);
      return true;
    };

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    _initializeForApp();

    await AppModules.inject();
    await injector.allReady();

    runApp(
      const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: ProviderScope(
          child: CleanerCore(),
        ),
      ),
    );
  }

  runZonedGuarded(() {
    startApp();
  }, (Object error, StackTrace stackTrace) {
    appLogger.error('Out-Side Framework', error, stackTrace);
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

void _initializeForApp() {
  workManagerInitialize();
}

class CleanerCore extends ConsumerStatefulWidget {
  const CleanerCore({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CleanerCoreState();
}

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'Main Navigator');

class _CleanerCoreState extends ConsumerState<CleanerCore> {
  @override
  void initState() {
    super.initState();

    NotificationServices.initialize();

    ref.read(appRepository).runAppGrowingService();
  }

  void _listenToPermissionChangesAndRunPhotoAnalysis() {
    ref.listen(permissionControllerProvider, (previous, next) {
      if (!next.hasValue) return;
      final nextValue = next.requireValue;

      if (nextValue.isFileGranted != true) return;
      if (previous?.valueOrNull?.isFileGranted != false) return;

      ref.read(fileManagerRepository).runPhotoAnalysisProcess();
    });
  }

  void _listenToPermissionChangesAndRunAppGrowingService() {
    ref.listen(permissionControllerProvider, (previous, next) {
      if (!next.hasValue) return;
      final nextValue = next.requireValue;

      if (nextValue.isUsageGranted != true) return;
      if (previous?.valueOrNull?.isUsageGranted != false) return;

      ref.read(appRepository).runAppGrowingService();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToPermissionChangesAndRunPhotoAnalysis();
    _listenToPermissionChangesAndRunAppGrowingService();
    appLogger.debug('Build CleanerCore');

    final themeMode = ref.watch<ThemeMode>(cleanerThemeNotifier);
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          FlutterError.presentError(errorDetails);
          return ErrorPage(
            errorCode: ErrorCode.internalError,
            errorDescription: errorDetails.exception.toString(),
          );
        };
        // return const IntroductionPage();
        return child ?? const SizedBox.shrink();
      },
      title: 'Phone Cleaner',
      theme: themeLight,
      darkTheme: themeDark,
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}

final generalInfoRepository =
    Provider<GeneralInfoManager>((ref) => GeneralInfoManager());

final fileManagerRepository = Provider<FileManager>((ref) => FileManager());

final appRepository = Provider<AppManager>((ref) => AppManager());

final goRouterProvider = Provider<GoRouter>((ref) => AppRouter.router);
