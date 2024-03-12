import 'package:flutter/material.dart';
import 'package:monetization/monetization.dart';

mixin BannerMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    AdManager.instance.showBanner(0);
  }

  @override
  void dispose() {
    AdManager.instance.hideBanner();
    super.dispose();
  }
}
