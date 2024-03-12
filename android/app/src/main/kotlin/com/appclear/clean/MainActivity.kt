package com.appclear.clean

import android.view.LayoutInflater
import com.appclear.clean.ad.NativeAd
import com.appclear.clean.ad.NativeAdSize
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(GoogleMobileAdsPlugin())
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "small_native_ad", NativeAd(LayoutInflater.from(context), NativeAdSize.Small)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "big_native_ad", NativeAd(LayoutInflater.from(context), NativeAdSize.Big)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "big_native_ad")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "small_native_ad")
    }
}
