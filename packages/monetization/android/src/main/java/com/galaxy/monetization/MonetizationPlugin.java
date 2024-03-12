package com.galaxy.monetization;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;


/** MonetizationPlugin */
public class MonetizationPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "monetization");
    channel.setMethodCallHandler(this);
    GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterPluginBinding.getFlutterEngine(),
            "optimal_size_native_ad_view",
            new OptimalSizeNativeAdFactory(flutterPluginBinding.getApplicationContext()));

    GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterPluginBinding.getFlutterEngine(),
            "optimal_size_native_ad_view_flat",
            new OptimalSizeNativeAdFlatFactory(flutterPluginBinding.getApplicationContext()));
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);

    GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            binding.getFlutterEngine(),
            "optimal_size_native_ad_view");

    GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            binding.getFlutterEngine(),
            "optimal_size_native_ad_view_flat");
  }
}
