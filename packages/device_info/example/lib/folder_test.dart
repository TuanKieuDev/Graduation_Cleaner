import 'package:flutter/material.dart';

class FolderManagerTest<T> extends StatefulWidget {
  const FolderManagerTest(
      {super.key, required this.future, this.split = false});
  final Future<List<T>> future;
  final bool split;

  @override
  State<FolderManagerTest> createState() => _FolderManagerTestState();
}

class _FolderManagerTestState extends State<FolderManagerTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: widget.future,
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
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                SizedBox(
                    width: double.infinity,
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          data.length.toString(),
                          style: const TextStyle(fontSize: 24),
                        ))),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var info = data[index].toString();
                      info = info.substring(
                          info.indexOf('(') + 1, info.length - 1);
                      var result = info.split(', ');

                      if (!widget.split) {
                        return Text(data[index]);
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < result.length; i++)
                              // Text(result[i].toString()),
                              RichText(
                                text: TextSpan(
                                    text: result[i]
                                        .substring(0, result[i].indexOf(': ')),
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                    children: [
                                      TextSpan(
                                          text: result[i]
                                              .substring(result[i].indexOf(':')),
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(fontSize: 20))
                                    ]),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
