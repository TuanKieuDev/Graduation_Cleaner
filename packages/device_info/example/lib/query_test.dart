import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class QueryTest extends StatelessWidget {
  const QueryTest({super.key});

  @override
  Widget build(BuildContext context) {
    var stopWatch = Stopwatch()..start();
    final future = FileManager().isolateQuery(
      {
        SystemEntityType.emptyFolder: null,
        SystemEntityType.screenshot: null,
        SystemEntityType.thumbnail: null,
        SystemEntityType.visibleCache: null,
        SystemEntityType.appData: null,
        SystemEntityType.downloaded: null,
        SystemEntityType.installedApk: null,
        SystemEntityType.mediaFile: null,
        SystemEntityType.image: null,
        SystemEntityType.audio: null,
        SystemEntityType.video: null,
        SystemEntityType.largeOldVideo:
            const LargeOldFileParameter(Duration(days: 30), 100000000),
        SystemEntityType.largeOldFile:
            const LargeOldFileParameter(Duration(days: 30), 104857600),
      },
    );
    future.whenComplete(() {
      stopWatch.stop();
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            var data = snapshot.data!;
            var entries = data.entries;

            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                      'the operation took: ${stopWatch.elapsedMilliseconds.toString()}ms'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries.elementAt(index);
                      final key = entry.key;
                      final values = entry.value;

                      var isImage = values.isNotEmpty &&
                          (values.first is FileInfo) &&
                          (values.first as FileInfo).isImage;
                      var path =
                          isImage ? (values.first as FileInfo).path : null;

                      return ExpansionTile(
                        title: Text(key.name),
                        subtitle: Text(values.length.toString()),
                        children: [
                          for (var i = 0; i < values.length; i++)
                            _QueryTestItem(values[i].toString(), path)
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QueryTestItem extends StatelessWidget {
  final String data;
  final String? imagePath;

  const _QueryTestItem(this.data, this.imagePath);

  @override
  Widget build(BuildContext context) {
    var info = data.toString();
    info = info.substring(info.indexOf('(') + 1, info.length - 1);
    var result = info.split(', ');
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagePath != null)
            SizedBox(
                height: 50,
                child: Image.file(
                  File(imagePath!),
                  cacheWidth: 120,
                )),
          for (var i = 0; i < result.length; i++)
            if (!result[i].contains(':'))
              Text(result[i].toString())
            else
              RichText(
                text: TextSpan(
                    text: result[i].substring(0, result[i].indexOf(':')),
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                    children: [
                      TextSpan(
                          text: result[i].substring(result[i].indexOf(':')),
                          style: DefaultTextStyle.of(context)
                              .style
                              .copyWith(fontSize: 20))
                    ]),
              )
        ],
      ),
    );
  }
}
