import 'package:phone_cleaner/di/injector.dart';
import 'package:phone_cleaner/services/preference_services/shared_preferences_manager.dart';
import 'package:phone_cleaner/src/commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:monetization/monetization.dart';

import '../../../introduction/views/intro_page.dart';
import '../src.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool? firstTime;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getFirstRun();
    });
  }

  Future<void> getFirstRun() async {
    final isFirst =
        await injector.get<SharedPreferencesManager>().getFirstLaunch() == null;
    if (isFirst) {
      setState(() {
        firstTime = true;
      });

      AdManager.instance.preventAdFor(newUserAdDelayDuration);
    } else {
      setState(() {
        firstTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (firstTime == null) {
      return const Scaffold();
    }
    if (firstTime!) {
      return const IntroductionPage();
    }
    return const HomePage();
  }
}
