package com.rocket.device.info.strange_code.low_photo_detection;

import android.content.ContentValues;
import android.content.Context;
import android.util.Log;

import com.rocket.device.info.strange_code.PhotoInfo;
import com.rocket.device.info.data.sql.entry.MediaDbEntry;
import com.rocket.device.info.data.sql.helper.MediaDbHelper;

import java.util.List;

public class LowQualityPhotoDetection {

    private void m35302(List<sr2> list){
        // update database
    }

    public static final mm m35303(List<PhotoInfo> list) {
        mm ˋ = m35306(list);
        return ˋ;
    }

    private static final void m35304(PhotoInfo sr2, mm mmVar) {
        sr2.setBadPhoto(false);
        m35305(sr2, mmVar);
        //sr2.m43204(true);
        //Log.d("PhotoAnalysisProcess", "Bad Image: " + sr2.getPath() + " --- " + sr2.isBadPhoto());
    }

    private static final void m35305(PhotoInfo sr2, mm mmVar) {
        if (sr2.getBlurry() < mmVar.m40468()) {
            sr2.setBadPhoto(true);
            //sr2.m43239(System.currentTimeMillis());
        }
        if (sr2.getDark() < mmVar.m40469()) {
            sr2.setBadPhoto(true);
            //sr2.m43239(System.currentTimeMillis());
        }
        if (sr2.getScore() >= 0.0d && sr2.getScore() < mmVar.m40470()) {
            sr2.setBadPhoto(true);
            //sr2.m43239(System.currentTimeMillis());
        }
    }

    private static final mm m35306(List<PhotoInfo> list) {
        ᔿ ᔿ = new ᔿ();
        ᔿ ᔿ2 = new ᔿ();
        for (PhotoInfo sr2 : list) {
            try {
                double ˎ = sr2.getBlurry();
                if (ˎ >= 0.0d) {
                    ᔿ.m47030((float) ˎ);
                }
                double ˉ = sr2.getScore();
                if (ˉ >= 0.0d) {
                    ᔿ2.m47030((float) ˉ);
                }
            } catch (Throwable th) {
//                DebugLog.m70920(th.getMessage());
            }
        }
        return new mm(null, 0.1d, (double) ᔿ.m47032(2), (double) ᔿ2.m47032(2));
    }

    public static final void startDetection(Context context, mm ʼ, PhotoInfo photo) {

        MediaDbHelper dbHelper = new MediaDbHelper(context);

        m35304(photo, ʼ);

        if(photo.isBadPhoto()){
            markAsLowQualityPhoto(dbHelper, photo.getPath());
        }

        dbHelper.close();
    }

    private static void markAsLowQualityPhoto(MediaDbHelper dbHelper, String path){
        ContentValues values = new ContentValues();
        values.put(MediaDbEntry.COLUMN_NAME_IS_BAD_PHOTO, 1);
        values.put(MediaDbEntry.COLUMN_NAME_WAS_ANALYZED_FOR_BAD_PHOTO, 1);
        dbHelper.updatePhotoInfoByPath(path, values);
    }

}
