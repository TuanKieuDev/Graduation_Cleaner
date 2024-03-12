import 'dart:async';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:meta/meta.dart';

import '../monetization.dart';

mixin AdLoaderMixin {
  int _retryAttempt = 0;

  AdType get adType;

  load();

  @protected
  void retryLoading() async {
    _retryAttempt++;
    final delayedTime = pow(2, min(6, _retryAttempt)).toInt();
    dev.log('attempting to reload after $delayedTime');
    await Future.delayed(Duration(seconds: delayedTime));
    load();
  }

  @protected
  void onAdLoadSucceeded() {
    _retryAttempt = 0;
    _adLoadedStreamControlller?.add(adType);
  }

  @protected
  void onAdDismissed() {
    _adDismissedStreamControlller?.add(adType);
  }

  @protected
  void onAdShowFailed() {
    _adShowFailedStreamControlller?.add(adType);
  }

  @protected
  void onAdShowed() {
    _adShowedStreamControlller?.add(adType);
  }

  StreamController<AdType>? _adLoadedStreamControlller;
  StreamController<AdType>? _adDismissedStreamControlller;
  StreamController<AdType>? _adShowFailedStreamControlller;
  StreamController<AdType>? _adShowedStreamControlller;

  Stream<AdType> get adLoadedStream {
    _adLoadedStreamControlller ??= StreamController.broadcast();

    return _adLoadedStreamControlller!.stream;
  }

  Stream<AdType> get adDismissedStream {
    _adDismissedStreamControlller ??= StreamController.broadcast();

    return _adDismissedStreamControlller!.stream;
  }

  Stream<AdType> get adFailedToShowFullScreenContentStream {
    _adShowFailedStreamControlller ??= StreamController.broadcast();

    return _adShowFailedStreamControlller!.stream;
  }

  Stream<AdType> get adShowedFullScreenContentStream {
    _adShowedStreamControlller ??= StreamController.broadcast();

    return _adShowedStreamControlller!.stream;
  }
}
