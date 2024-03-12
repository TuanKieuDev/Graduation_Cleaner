import 'dart:math';

import 'package:flutter/services.dart';

class FakeData {
  Future<Uint8List> get facebook async {
    var byteData = await rootBundle.load('assets/fake_data/icons/facebook.svg');
    return (byteData)
        .buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  }

  Future<Uint8List> get twitter async {
    var byteData = await rootBundle.load('assets/fake_data/icons/twitter.svg');
    return (byteData)
        .buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  }

  Future<Uint8List> get youtube async {
    var byteData = await rootBundle.load('assets/fake_data/icons/youtube.svg');
    return (byteData)
        .buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  }

  Stream<Uint8List> takeRandomIconsAsync(int count) async* {
    const ids = [1, 2, 3];
    final random = Random();
    for (int i = 0; i < count; i++) {
      final id = random.nextInt(ids.length);
      late Future<Uint8List> result;
      switch (id) {
        case 0:
          result = facebook;
          break;
        case 1:
          result = twitter;
          break;
        case 2:
          result = youtube;
          break;
        default:
      }
      yield await result;
    }
  }
}
