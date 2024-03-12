import 'package:phone_cleaner/src/commons/widgets/lottie_looper.dart';
import 'package:flutter/material.dart';

class SavingTipsLoading extends StatelessWidget {
  const SavingTipsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LottieLooper(
          'assets/lotties/tips_loading.json',
          height: 150,
          width: 150,
        ),
      ),
    );
  }
}
