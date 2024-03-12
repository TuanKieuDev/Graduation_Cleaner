package com.rocket.device.info.strange_code.similar_detection;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.PointF;
import android.util.Log;

import com.davemorrissey.labs.subscaleview.SubsamplingScaleImageView;
import com.rocket.device.info.strange_code.PhotoInfo;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import org.opencv.android.OpenCVLoader;
import org.opencv.android.Utils;
import org.opencv.calib3d.Calib3d;
import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.MatOfDouble;
import org.opencv.core.MatOfFloat;
import org.opencv.core.MatOfInt;
import org.opencv.core.MatOfRect;
import org.opencv.core.Rect;
import org.opencv.core.Size;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;
import org.opencv.objdetect.CascadeClassifier;

public class OpenCVOperation {
    private static final String TAG = "OpenCVOperation";

    /* renamed from: ᴵ */
    private static CascadeClassifier classifier;

    public OpenCVOperation() {
        String str = "CvScore() failed init opencv";
        try {
            if (OpenCVLoader.initDebug()) {
                m43698();
            } else {

            }
        } catch (Exception unused) {

        }
    }

    /* renamed from: ʾ */
    private Mat readMatFromInputStream(InputStream inputStream) throws IOException {

        // only image types with the following extensions are supported: .jpg, .jpeg, .png, .bmp, .tif, .tiff, .gif, .webp

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream(inputStream.available());
        byte[] bArr = new byte[Calib3d.CALIB_FIX_K5];
        while (true) {
            int read = inputStream.read(bArr);
            if (read != -1) {
                byteArrayOutputStream.write(bArr, 0, read);
            } else {
                inputStream.close();
                Mat mat = new Mat(1, byteArrayOutputStream.size(), 0);
                mat.put(0, 0, byteArrayOutputStream.toByteArray());
                byteArrayOutputStream.close();
                Mat imdecode = Imgcodecs.imdecode(mat, -1);
                mat.release();
                return imdecode;
            }
        }
    }

    /* renamed from: ˈ */
    private static void m43698() {
        try {
            InputStream openRawResource = tr8.m70096().getApplicationContext().getResources().openRawResource(l14.f33381);
            File file = new File(tr8.m70096().getApplicationContext().getDir("cascade", 0), "lpcascade_frontalface_alt.xml");
            FileOutputStream fileOutputStream = new FileOutputStream(file);
            byte[] bArr = new byte[Calib3d.CALIB_FIX_K5];
            while (true) {
                int read = openRawResource.read(bArr);
                if (read != -1) {
                    fileOutputStream.write(bArr, 0, read);
                } else {
                    openRawResource.close();
                    fileOutputStream.close();
                    classifier = new CascadeClassifier(file.getAbsolutePath());
                    return;
                }
            }
        } catch (IOException e) {
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.append("Failed to load cascade. Exception thrown: ");
            stringBuilder.append(e);
        }
    }

    /* renamed from: ʻ */
    public double calculateImageBrightness(Mat mat) {
        double brightness = 1.0;
        MatOfInt histogramChannel = new MatOfInt(0);
        MatOfInt histogramSize = new MatOfInt(256);
        MatOfFloat histogramRange = new MatOfFloat(0.0f, 256.0f);
        Mat histogram = new Mat();
        Mat convertedImage = new Mat();
        try {
            if (mat.empty()){
                return brightness;
            }
            Imgproc.cvtColor(mat, convertedImage, Imgproc.COLOR_BGR2GRAY);
            int rows = mat.rows() * mat.cols();
            Imgproc.calcHist(Collections.singletonList(mat), histogramChannel, new Mat(), histogram, histogramSize, histogramRange);
            int i = 0;
            int i2 = i;
            while (i < 30) {
                i2 = (int) (((double) i2) + histogram.get(i, 0)[0]);
                i++;
            }
            brightness = ((((double) i2) / (((double) rows))) - 1.0d) * -1.0d;
        } catch (Throwable th) {
            histogramChannel.release();
            histogramSize.release();
            histogramRange.release();
            histogram.release();
            convertedImage.release();
        }
        histogramChannel.release();
        histogramSize.release();
        histogramRange.release();
        histogram.release();
        convertedImage.release();
        return brightness;
    }

    /* renamed from: ʼ */
    public double compareHistograms(Mat mat1, Mat mat2) {
        try {
            Mat hist1 = calculateHistogram(mat1);
            Mat hist2 = calculateHistogram(mat2);
            assert hist1 != null;
            assert hist2 != null;
            return Imgproc.compareHist(hist1, hist2, Imgproc.CV_COMP_CORREL);
        } catch (Exception e) {
            //Log.d(TAG, "Failed to compare calculate histogram", e);
            return -1.0;
        }
    }

    private Mat calculateHistogram(Mat mat) {
        Mat hist = new Mat();
        MatOfInt channels = new MatOfInt(0);
        MatOfInt histSize = new MatOfInt(16);
        MatOfFloat ranges = new MatOfFloat(0.0f, 256.0f);
        try {
            Imgproc.calcHist(Collections.singletonList(mat), channels, new Mat(), hist, histSize, ranges);
        } catch (Exception e) {
            //Log.d(TAG, "Failed to calculate histogram", e);
            return null;
        } finally {
            channels.release();
            histSize.release();
            ranges.release();
        }
        return hist;
    }

    /* renamed from: ʿ */
    public ArrayList<ly0> detectFaces(Mat image) {
        Mat grayscaleImage = new Mat();
        Rect[] toArray;
        ArrayList<ly0> arrayList;
        try {
            if (image.channels() >= 3) {
                Imgproc.cvtColor(image, grayscaleImage, Imgproc.COLOR_BGR2GRAY);
            } else {
                grayscaleImage = image.clone();
            }
            MatOfRect matOfRect = new MatOfRect();
            double round = (double) Math.round(((double) grayscaleImage.height()) * 0.1d);
            classifier.detectMultiScale(grayscaleImage, matOfRect, 1.2d, 2, 2, new Size(round, round), grayscaleImage.size());
            toArray = matOfRect.toArray();
            arrayList = new ArrayList<>(toArray.length);
            for (Rect rect : toArray) {
                PointF pointF = new PointF();
                pointF.x = (((float) rect.x) + (((float) rect.width) / 2.0f)) / ((float) grayscaleImage.width());
                pointF.y = (((float) rect.y) + (((float) rect.height) / 2.0f)) / ((float) grayscaleImage.height());
                arrayList.add(new ly0(pointF, (((float) Math.max(rect.width, rect.height)) + 0.0f) / ((float) grayscaleImage.width()), 0.0f));
            }
            return arrayList;
        } catch (Throwable th) {
            return new ArrayList<ly0>(0);
        } finally {
            grayscaleImage.release();
        }
    }


    private final int m34804(BitmapFactory.Options options, int i, int i2) {
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
    private final Bitmap m34801(String str, int i, int i2) {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        options.inSampleSize = m34804(options, i, i2);
        options.inPreferredConfig = Bitmap.Config.RGB_565;
        return BitmapFactory.decodeFile(str, options);
    }

    public Mat readMatFromPath(Context context, PhotoInfo PhotoInfo, boolean z) {
        Mat imageMat = null;
        InputStream fileInputStream = null;
        try {
            if (PhotoInfo.getPath() != null && z) {
                fileInputStream = new FileInputStream(PhotoInfo.getPath());
                imageMat = readMatFromInputStream(fileInputStream);

                if (imageMat.empty()) {
                    try {
                        Bitmap bitmap = bj3.f29804.m34810(context, PhotoInfo);
                        if(bitmap == null){
                            bitmap = BitmapFactory.decodeFile(PhotoInfo.getPath());
                        }
                        if (bitmap != null) {
                            imageMat = new Mat();
                            Utils.bitmapToMat(bitmap, imageMat);
                            bitmap.recycle();
                        } else {
                            StringBuilder stringBuilder = new StringBuilder();
                            stringBuilder.append(PhotoInfo.getPath());
                            stringBuilder.append(" null bitmap");
                            return null;
                        }
                    } catch (Throwable th) {
                        return null;
                    }
                }
                Mat mat2 = new Mat();
                if (PhotoInfo.getOrientation() == SubsamplingScaleImageView.ORIENTATION_270) {
                    Core.flip(imageMat.t(), mat2, 0);
                    return mat2;
                } else if (PhotoInfo.getOrientation() == SubsamplingScaleImageView.ORIENTATION_180) {
                    Core.flip(imageMat, mat2, -1);
                    return mat2;
                } else if (PhotoInfo.getOrientation() == 90) {
                    Core.flip(imageMat.t(), mat2, 1);
                    return mat2;
                }
                // mat = mat2;
                return imageMat;
            }
            // TODO: Suspicious code
//            fileInputStream = null;
//            return null;
//            imageMat = readMatFromInputStream(fileInputStream);
//            if (fileInputStream != null) {
//            }
        } catch (Throwable th2) {
            Throwable th3 = th2;
//            imageMat = null;
//            if (imageMat == null) {
//            }
//            if (!imageMat.empty()) {
//            }
        } finally {
            if (fileInputStream != null) {
                try {
                    fileInputStream.close();
                } catch (IOException e) {
                    //Log.d("PhotoAnalysis", "Error closing input stream for path " + PhotoInfo.getPath(), e);
                }
            }
        }
        return imageMat;
    }

    /* renamed from: ˊ */
    public double calculatePhotoScore(PhotoInfo PhotoInfo) {
        double score = ((((PhotoInfo.getBlurry() > 0.02d ? 0.1d : 0.0d) + (PhotoInfo.getBlurry() * 0.2d)) + (PhotoInfo.getDark() * 0.2d)) + (PhotoInfo.getColor() > 0.2d ? 0.1d : 0.0d)) + (PhotoInfo.getColor() * 0.3d);
        double d = 1.0d;
        if (PhotoInfo.getFacesCount() > 0) {
            d = (((double) PhotoInfo.getFacesCount()) * 0.1d) + 0.1d;
        }
        return score + d;
    }


    /* renamed from: ˋ */
    public double calculateBlurryValue(Mat src) {
        try {
            if (src.empty()){
                return 0.0d;
            }
            Mat mat = new Mat();
            if (src.channels() >= 3) {
                Imgproc.cvtColor(src, mat, Imgproc.COLOR_BGR2GRAY); // convert to COLOR_BGR2GRAY color space
                src = mat;
            }
            mat = new Mat();
            Imgproc.Laplacian(src, mat, 3);
            MatOfDouble mean = new MatOfDouble();
            MatOfDouble stdDev = new MatOfDouble();
            Core.meanStdDev(mat, mean, stdDev);
            src.release();
            mat.release();
            double d = stdDev.get(0, 0)[0];
            mean.release();
            stdDev.release();
            return d < 15.0d ? Double.valueOf((d / 15.0d) * 0.1d) : d > 35.0d ? Double.valueOf(Math.min((((d - 35.0d) / 15.0d) * 0.1d) + 0.9d, 1.0d)) : Double.valueOf((d - 12.5d) / 25.0d);
        } catch (Throwable th) {
            return 0.0d;
        }
    }

    /**
     * Calculates the blurriness of an image based on the sharpness of its edges.
     * @param image the input image
     * @return a value between 0 (very blurry) and 1 (very sharp)
     */
    public double calculateImageSharpness(Mat image) {
        double sharpness = 1.0;
        MatOfInt channels = new MatOfInt(0, 1);
        MatOfInt histogramSize = new MatOfInt(4, 4);
        MatOfFloat histogramRange = new MatOfFloat(0.0f, 256.0f, 0.0f, 256.0f);
        Mat histogram = new Mat();
        try {
            if (image.empty()) {
                return sharpness;
            }
            int rows = image.rows() * image.cols();
            Imgproc.calcHist(Collections.singletonList(image), channels, new Mat(), histogram, histogramSize, histogramRange);
            double variance = 0.0d;
            for (int i = 0; i < histogram.rows(); i++) {
                for (int i2 = 0; i2 < histogram.rows(); i2++) {
                    variance += Math.pow(histogram.get(i, i2)[0] - ((double) (rows / 16)), 2.0d);
                }
            }
            variance = 1.0d - (Math.pow(variance, 0.5d) / ((double) rows));
            sharpness = variance < 0.5d ? Double.valueOf(variance / 5.0d) : Double.valueOf(Math.min((variance - 0.4d) * 2.25d, 1.0d));
        } catch (Throwable th) {
            // ignore
        } finally {
            channels.release();
            histogramSize.release();
            histogramRange.release();
            histogram.release();
        }

        return sharpness;
    }
}
