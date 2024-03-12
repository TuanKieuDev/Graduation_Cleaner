import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CleanerThemeMode extends StateNotifier<ThemeMode> {
  CleanerThemeMode([ThemeMode themeMode = ThemeMode.light]) : super(themeMode) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness:
            themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light));
  }

  void setTheme(ThemeMode mode) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness:
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light));
    state = mode;
  }
}

final cleanerThemeNotifier = StateNotifierProvider<CleanerThemeMode, ThemeMode>(
    (ref) => CleanerThemeMode());
