import 'package:monetization/src/ad_helper.dart';

class AdInterval {
  Duration interval = AdHelper.interAdsInterval;

  DateTime _lastDisplayedTime = DateTime(0);

  void updateAdShowedTime() {
    _lastDisplayedTime = DateTime.now();
  }

  bool shouldShowAd() =>
      _lastDisplayedTime.add(interval).isBefore(DateTime.now());
}
