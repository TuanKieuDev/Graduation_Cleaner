import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';

class ApplicationList extends StatelessWidget {
  const ApplicationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: AppManager().getAllApplications(),
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
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final app = data[index];
              return ListTile(
                leading: FutureBuilder(
                    future: AppManager().getIcon(app.packageName),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      return Image.memory(snapshot.data!);
                    }),
                title: FutureBuilder(
                  future: AppManager().getLabel(app.packageName),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    return Text(snapshot.data!);
                  },
                ),
                subtitle: Text(app.packageName),
              );
            },
          );
        },
      ),
    );
  }
}
