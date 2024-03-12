import 'package:phone_cleaner/src/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class BoostLoading extends ConsumerStatefulWidget {
  const BoostLoading({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BoostLoadingState();
}

class _BoostLoadingState extends ConsumerState<BoostLoading> {
  @override
  Widget build(BuildContext context) {
    ref.watch(quickBoostControllerProvider);

    return Scaffold(
      body: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height,
          child: Lottie.asset('assets/lotties/boost.json')),
    );
  }
}
