package com.rocket.device.info.strange_code.similar_detection;

import android.content.Context;
import android.util.Log;

import com.rocket.device.info.strange_code.PhotoInfo;

import java.util.ArrayList;
import org.opencv.core.Mat;

public final class PhotoScoreDetection {

    private final Context f36347;

    private final OpenCVOperation f36349;

    public PhotoScoreDetection(Context context) {
        this.f36347 = context;
        this.f36349 = new OpenCVOperation();
    }

    /* renamed from: ˊ */
    public void calculatePhotoScore(PhotoInfo photoInfo) {
        Mat mat = null;

        try {
            mat = this.f36349.readMatFromPath(this.f36347, photoInfo, true);
            if (mat == null) {
                return;
            }

            if (mat.empty()){
                Log.e("PhotoDetection", "Failed to analyze photo " + photoInfo.getPath() + ". Mat empty.");
                return;
            }

//        Log.wtf("PhotoDetection", "blurry");
            double m43704 = this.f36349.calculateBlurryValue(mat);
            //b22.m34190(m43704, "cvFeature.getBlurry(mat)");
            photoInfo.setBlurry(m43704);
//        Log.wtf("PhotoDetection", "sharpness");
            m43704 = this.f36349.calculateImageSharpness(mat);
            ////Log.d("BadPhoto", photoInfo.getPath());
            //b22.m34190(m43704, "cvFeature.getColor(mat)");
            photoInfo.setColor(m43704);
//        Log.wtf("PhotoDetection", "brightness");
            m43704 = this.f36349.calculateImageBrightness(mat);
            //b22.m34190(m43704, "cvFeature.getDark(mat)");
            photoInfo.setDark(m43704);
            photoInfo.setCvAnalyzed(true);
//        Log.wtf("PhotoDetection", "faces");
            if (photoInfo.getFacesCount() == 0) {
                ArrayList<ly0> faces = this.f36349.detectFaces(mat);
                //b22.m34190(ʿ, "cvFeature.openCvFaceDetection(mat)");
                photoInfo.setFacesCount(faces.size());
            }
            mat.release();
//        Log.wtf("PhotoDetection", "score");
            double score = this.f36349.calculatePhotoScore(photoInfo);
            //b22.m34190(ˊ, "cvFeature.calcScore(mediaDbItem)");
            photoInfo.setScore(score);
        } catch (Throwable e) {
            Log.e("PhotoDetection", "Failed to analyze photo " + photoInfo.getPath(), e);
        } finally {
            if (mat != null) {
                mat.release();
            }
        }
    }
}
