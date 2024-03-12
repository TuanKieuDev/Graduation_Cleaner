import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUnncessaryDataTestView extends ConsumerStatefulWidget {
  const AppUnncessaryDataTestView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AppUnncessaryDataTestViewState();
}

class _AppUnncessaryDataTestViewState
    extends ConsumerState<AppUnncessaryDataTestView> {
  var unnecessaryData = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Unncessary Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Số lượng rác không cần thiết: $unnecessaryData'),
            ElevatedButton(
              onPressed: () async {
                final data = await AppManager().getUnnecessaryData();
                setState(() {
                  unnecessaryData = data;
                });
              },
              child: const Text('Lấy dữ liệu'),
            ),
          ],
        ),
      ),
    );
  }
}
