import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monetization/monetization.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: AdDemo(),
      ),
    );
  }
}

class AdDemo extends StatefulWidget {
  const AdDemo({super.key});

  @override
  State<AdDemo> createState() => _AdDemoState();
}

class _AdDemoState extends State<AdDemo> {
  late StreamSubscription adOpenStreamSubscription;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    AdManager.instance.initialize().then((value) {
      setState(() {});
      initialized = true;
    });
    adOpenStreamSubscription = AdManager.instance.adLoaded.listen((adType) {
      if (adType == AdType.appOpen) {
        AdManager.instance.showAds(adType);
        adOpenStreamSubscription.cancel();
      }
    });

    Future.delayed(const Duration(seconds: 7)).then((value) {
      adOpenStreamSubscription.cancel();
      AdManager.instance.listenToAndOpenAdOnAppStateChanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      children: [
        TextButton(
          onPressed: () => AdManager.instance.showAds(AdType.interstitial),
          child: const Text('Show interstitial'),
        ),
        const SizedBox(
          height: 24,
        ),
        TextButton(
          onPressed: () => AdManager.instance.showAds(AdType.appOpen),
          child: const Text('Show appOpen'),
        ),
        const SizedBox(
          height: 24,
        ),
        TextButton(
          onPressed: () => AdManager.instance.showBanner(0),
          child: const Text('Display banner'),
        ),
        const SizedBox(
          height: 24,
        ),
        TextButton(
          onPressed: () => AdManager.instance.hideBanner(),
          child: const Text('Hide banner'),
        ),
        const SizedBox(
          height: 24,
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return const BannerCenterDemo();
            },
          )),
          child: const Text('Banner Center Demo'),
        ),
        const SizedBox(
          height: 24,
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: NativeAdOptimalSize(
            storageId: 'big_native_ad',
          ),
        ),
      ],
    );
  }
}

class BannerCenterDemo extends StatelessWidget {
  const BannerCenterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          const Banner(),
          Container(
            color: Colors.red,
            height: 300,
            width: double.infinity,
          ),
          Container(
            color: Colors.red,
            height: 300,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class Banner extends StatefulWidget {
  const Banner({super.key});

  @override
  State<Banner> createState() => _BannerState();
}

class _BannerState extends State<Banner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderObject = context.findRenderObject() as RenderBox;

      var offset = renderObject.localToGlobal(Offset.zero);
      var height = MediaQuery.of(context).size.height;
      print(
          'demo $height $offset ${renderObject.size} ${offset.dy.toInt() - height.toInt()} ${MediaQuery.of(context).devicePixelRatio}');
      AdManager.instance.showBanner(
          (offset.dy * MediaQuery.of(context).devicePixelRatio).toInt());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 50,
      width: 320,
    );
  }
}
