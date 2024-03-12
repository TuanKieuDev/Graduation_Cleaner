package com.rocket.device.info.strange_code.similar_detection;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
import android.graphics.BitmapFactory.Options;
import android.graphics.ImageDecoder;
import android.graphics.ImageDecoder.ImageInfo;
import android.graphics.ImageDecoder.Source;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Build.VERSION;
import android.provider.MediaStore.Images.Media;
import android.provider.MediaStore.Images.Thumbnails;

import com.davemorrissey.labs.subscaleview.SubsamplingScaleImageView;
import com.rocket.device.info.strange_code.PhotoInfo;

import java.io.IOException;
//import com.davemorrissey.labs.subscaleview.SubsamplingScaleImageView;
//import eu.inmite.android.fw.DebugLog;
//import java.io.IOException;

public final class bj3 {
    /* renamed from: ˊ */
    public static final bj3 f29804 = new bj3();

    private bj3() {
    }

    /* renamed from: ʻ */
    private final Bitmap m34801(String str, int i, int i2) {
        Options options = new Options();
        options.inJustDecodeBounds = true;
        options.inSampleSize = m34804(options, i, i2);
        options.inPreferredConfig = Config.RGB_565;
        return BitmapFactory.decodeFile(str, options);
    }

    /* renamed from: ʼ */
    @SuppressLint("NewApi")
    private final Bitmap m34802(ContentResolver contentResolver, PhotoInfo PhotoInfo) {
        try {
            Uri withAppendedId = ContentUris.withAppendedId(Media.EXTERNAL_CONTENT_URI, PhotoInfo.getAndroidId());
            return ImageDecoder.decodeBitmap(ImageDecoder.createSource(contentResolver, withAppendedId), aj3.f48981);
        } catch (IOException e) {
            String ˈ = PhotoInfo.getPath();
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.append("PhotoAnalyzerUtils.createBitmapForThumbnail() - failed on api 29+ for item: ");
            stringBuilder.append(ˈ);
            stringBuilder.append(", ");
            stringBuilder.append(e);
            return null;
        }
    }

    /* JADX WARNING: Missing block: B:3:0x0010, code skipped:
            if (r0 == null) goto L_0x0012;
     */
    /* Code decompiled incorrectly, please refer to instructions dump. */
    /* renamed from: ʾ */
    private final Bitmap m34803(Context context, PhotoInfo PhotoInfo) {
        Bitmap ᐝ;
        String ˌ = PhotoInfo.getPath();
        if (ˌ != null) {
            ᐝ = f29804.m34807(ˌ, PhotoInfo.getOrientation());
        }
        ᐝ = m34809(context, PhotoInfo);
        return ᐝ != null ? m34808(ᐝ, PhotoInfo.getOrientation()) : null;
    }

    /* renamed from: ˋ */
    private final int m34804(Options options, int i, int i2) {
        int i3 = options.outWidth;
        int i4 = options.outHeight;
        int i5 = 1;
        while (true) {
            int i6 = i3 / 2;
            if ((i6 < i || i4 / 2 < i2) && i3 < 2048 && i4 < 2048) {
                break;
            }
            i4 /= 2;
            i5 *= 2;
            i3 = i6;
        }
        return i5 < 1 ? 1 : i5;
    }

    /* renamed from: ˎ */
    private final void m34805(ContentResolver contentResolver, PhotoInfo PhotoInfo) {
        if (PhotoInfo.getPath() != null) {
            Uri uri = Thumbnails.EXTERNAL_CONTENT_URI;
            String[] strArr = new String[1];
            long ˊ = PhotoInfo.getAndroidId();
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.append(ˊ);
            strArr[0] = stringBuilder.toString();
            contentResolver.delete(uri, "image_id = ? ", strArr);
        }
    }

    public static int m44135(int i, int i2) {
        return i < i2 ? i2 : i;
    }

    @SuppressLint("NewApi")
    public static final void m34806(ImageDecoder imageDecoder, ImageInfo imageInfo, Source source) {
        imageDecoder.setAllocator(ImageDecoder.ALLOCATOR_SOFTWARE);
        int ˏ = m44135(imageInfo.getSize().getWidth() / 384, imageInfo.getSize().getHeight() / 512);
        if (ˏ > 1) {
            imageDecoder.setTargetSampleSize(ˏ);
        }
    }

    /* renamed from: ᐝ */
    private final Bitmap m34807(String str, int i) {
        return i % SubsamplingScaleImageView.ORIENTATION_180 != 0 ? m34801(str, 512, 384) : m34801(str, 384, 512);
    }

    /* renamed from: ι */
    private final Bitmap m34808(Bitmap bitmap, int i) {
        if (i <= 0) {
            return bitmap;
        }
        Matrix matrix = new Matrix();
        matrix.postRotate((float) i);
        Bitmap createBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
        bitmap.recycle();
        return createBitmap;
    }

    /* renamed from: ʽ */
    public final Bitmap m34809(Context context, PhotoInfo PhotoInfo) {
        Bitmap ʼ;
        ContentResolver contentResolver = context.getContentResolver();
        String str = "cr";
        if (VERSION.SDK_INT >= 29) {
            ʼ = m34802(contentResolver, PhotoInfo);
        } else {
            Options options = new Options();
            options.inSampleSize = 1;
            options.inPreferredConfig = Config.RGB_565;
            try {
                ʼ = Thumbnails.getThumbnail(contentResolver, PhotoInfo.getAndroidId(), 1, options);
            } catch (OutOfMemoryError unused) {
                ʼ = Thumbnails.getThumbnail(contentResolver, PhotoInfo.getAndroidId(), 1, options);
            }
        }
        m34805(contentResolver, PhotoInfo);
        return ʼ;
    }

    /* renamed from: ˏ */
    public final Bitmap m34810(Context context, PhotoInfo PhotoInfo) {
        try {
            return m34803(context, PhotoInfo);
        } catch (Throwable th) {
            String message = th.getMessage();
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.append("PhotoAnalyzerUtils.createBitmapForItem() - error while loading image: ");
            stringBuilder.append(message);
            return null;
        }
    }
}
