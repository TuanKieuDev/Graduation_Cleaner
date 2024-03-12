// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:monetization/monetization.dart';
import 'package:monetization/src/banner_mixin.dart';

class BannerAd extends StatefulWidget {
  const BannerAd({
    Key? key,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);
  final EdgeInsets padding;

  @override
  State<BannerAd> createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> with BannerMixin {
  @override
  Widget build(BuildContext context) {
    if (AdManager.instance.adRemoved) {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }
}
