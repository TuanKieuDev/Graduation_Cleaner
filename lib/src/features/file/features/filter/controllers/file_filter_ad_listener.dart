import 'package:phone_cleaner/src/features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// ignore: unused_element
final _fileFilterAdListenerProvider = Provider.autoDispose<void>((ref) =>
    ref.listen(
        fileFilterControllerProvider
            .selectAsync((data) => data.fileFilterParameter), (previous, next) {
      AdManager.instance.showAds(AdType.interstitial);
    }));
