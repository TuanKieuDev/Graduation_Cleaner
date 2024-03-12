import 'dart:io';

import 'package:flutter/material.dart';

class StreamCircleProgress extends StatelessWidget {
  const StreamCircleProgress({super.key, required this.stream});

  final Stream<FileSystemEntity> stream;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FileSystemEntity>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return const Text("data");
      },
    );
  }
}
