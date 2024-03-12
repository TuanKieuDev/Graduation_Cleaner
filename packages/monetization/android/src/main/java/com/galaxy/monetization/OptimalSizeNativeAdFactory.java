package com.galaxy.monetization;

import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.gms.ads.nativead.MediaView;
import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;

import java.util.Map;

import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class OptimalSizeNativeAdFactory implements GoogleMobileAdsPlugin.NativeAdFactory {

    private final Context context;

    OptimalSizeNativeAdFactory(Context context) {
        this.context = context;
    }

    @Override
    public NativeAdView createNativeAd(
            NativeAd nativeAd, Map<String, Object> customOptions) {
        NativeAdView nativeAdView = (NativeAdView) LayoutInflater.from(context)
                .inflate(R.layout.optimal_size_native_ad_view, null);

        ImageView iconView = nativeAdView.findViewById(R.id.native_ad_icon);
        NativeAd.Image icon = nativeAd.getIcon();
        if (icon != null) {
            iconView.setVisibility(View.VISIBLE);
            iconView.setImageDrawable(icon.getDrawable());
            nativeAdView.setIconView(iconView);
        } else {
            nativeAdView.findViewById(R.id.ad_distribution).setVisibility(View.GONE);
        }

        TextView headlineView = nativeAdView.findViewById(R.id.native_ad_headline);
        headlineView.setText(nativeAd.getHeadline());

        nativeAdView.setHeadlineView(headlineView);

        TextView bodyView = nativeAdView.findViewById(R.id.native_ad_body);
        bodyView.setText(nativeAd.getBody());
        bodyView.setVisibility(nativeAd.getBody() != null ? View.VISIBLE : View.GONE);
        nativeAdView.setBodyView(bodyView);

        headlineView.getViewTreeObserver().addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {

            @Override
            public boolean onPreDraw() {
                // Remove listener because we don't want this called before _every_ frame
                headlineView.getViewTreeObserver().removeOnPreDrawListener(this);

                // Drawing happens after layout so we can assume getLineCount() returns the correct value
                if(headlineView.getLineCount() > 1) {
                    bodyView.setVisibility(View.GONE);
                }

                return true; // true because we don't want to skip this frame
            }
        });

        MediaView adImage = nativeAdView.findViewById(R.id.native_ad_image);
        nativeAdView.setMediaView(adImage);

        Button button = nativeAdView.findViewById(R.id.native_ad_call_to_action);
        button.setText(nativeAd.getCallToAction());
        nativeAdView.setCallToActionView(button);

        nativeAdView.setNativeAd(nativeAd);

        return nativeAdView;
    }
}
