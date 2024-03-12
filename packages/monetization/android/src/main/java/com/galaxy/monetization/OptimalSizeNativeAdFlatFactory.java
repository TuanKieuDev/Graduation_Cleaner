package com.galaxy.monetization;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
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

public class OptimalSizeNativeAdFlatFactory implements GoogleMobileAdsPlugin.NativeAdFactory {

    private final Context context;

    OptimalSizeNativeAdFlatFactory(Context context) {
        this.context = context;
    }

    @Override
    public NativeAdView createNativeAd(
            NativeAd nativeAd, Map<String, Object> customOptions) {
        NativeAdView nativeAdView = (NativeAdView) LayoutInflater.from(context)
                .inflate(R.layout.optimal_size_native_ad_view, null);

        ImageView adDistribution = nativeAdView.findViewById(R.id.ad_distribution);
        adDistribution.getDrawable().setColorFilter(0xFF899499, PorterDuff.Mode.SRC_IN);

        String textColor = customOptions == null ? null : (String) customOptions.get("textColor");

        ImageView iconView = nativeAdView.findViewById(R.id.native_ad_icon);
        NativeAd.Image icon = nativeAd.getIcon();
        if (icon != null) {
            iconView.setVisibility(View.VISIBLE);
            iconView.setImageDrawable(icon.getDrawable());
            nativeAdView.setIconView(iconView);
        } else {
            adDistribution.setVisibility(View.GONE);
        }

        TextView headlineView = nativeAdView.findViewById(R.id.native_ad_headline);
        headlineView.setText(nativeAd.getHeadline());
        if (textColor != null){
            headlineView.setTextColor(Color.parseColor(textColor));
        }
        nativeAdView.setHeadlineView(headlineView);

        TextView bodyView = nativeAdView.findViewById(R.id.native_ad_body);
        bodyView.setTextColor(0xB3000000);
        if (textColor != null){
            bodyView.setTextColor(Color.parseColor(textColor));
        }
        bodyView.setText(nativeAd.getBody());
        bodyView.setVisibility(nativeAd.getBody() != null ? View.VISIBLE : View.INVISIBLE);
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
