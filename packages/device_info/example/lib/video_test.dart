import 'dart:io';

import 'package:flutter/material.dart';

class VideoTest extends StatelessWidget {
  const VideoTest({super.key, required this.future});

  final Future<List<String>> future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (snapshot.error is Exception) {
              FlutterError.presentError(
                  FlutterErrorDetails(exception: snapshot.error as Exception));
            } else {
              debugPrintStack(
                  stackTrace: snapshot.stackTrace,
                  label: snapshot.error.toString());
            }

            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(data.length.toString()),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      crossAxisCount: 3),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 300,
                      child: TextButton(
                        onPressed: (() => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(data[index]),
                              ),
                            )),
                        child: Image.file(
                          File(data[index]),
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint("$error\n path: ${data[index]}");
                            return Text(data[index]);
                          },
                          filterQuality: FilterQuality.low,
                          cacheHeight: 120,
                          height: 120,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
