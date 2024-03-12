package com.rocket.device.info.strange_code;

import android.app.NotificationManager;
import android.content.Context;
import android.media.ExifInterface;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.work.ExistingWorkPolicy;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.Worker;
import androidx.work.WorkerParameters;

import com.rocket.device.info.notification.NotificationConstant;
import com.rocket.device.info.notification.NotificationCreation;
import com.rocket.device.info.strange_code.similar_detection.SimilarPhotoDataHandler;
import com.rocket.device.info.services.FileManager;

import com.rocket.device.info.strange_code.low_photo_detection.LowQualityPhotoDetection;
import com.rocket.device.info.strange_code.low_photo_detection.mm;
import com.rocket.device.info.strange_code.similar_detection.PhotoScoreDetection;
import com.rocket.device.info.data.sql.helper.MediaDbHelper;
import com.rocket.device.info.models.FileInfo;
import com.rocket.device.info.settings.Permissions;

import java.util.ArrayList;
import java.util.List;

public class PhotoAnalysisWorker extends Worker {

    private NotificationCompat.Builder mBuilder;
    public PhotoAnalysisWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
        mBuilder = NotificationCreation.INSTANCE.createPhotoAnalysisNotificationBuilder(context);
    }

    public static void startAnalysis(Context context){
        OneTimeWorkRequest workRequest = new OneTimeWorkRequest.Builder(PhotoAnalysisWorker.class).build();

        WorkManager.getInstance(context)
                .enqueueUniqueWork("analyze_photo", ExistingWorkPolicy.KEEP, workRequest);
    }

    @NonNull
    @Override
    public Result doWork() {

        Context context = getApplicationContext();

        if(!Permissions.INSTANCE.isStoragePermissionGranted(context)){
            PhotoAnalysisService.stopService(context);
            return Result.failure();
        }

        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        mBuilder.setProgress(100, 0, false); // 0%
        notificationManager.notify(NotificationConstant.PHOTO_ANALYSIS_NOTIFICATION_ID, mBuilder.build());

        try {
            //Log.d("PhotoAnalysisProcess", "PhotoAnalysisProcess: Get All Photos Info");
            List<PhotoInfo> photos = PhotoAnalysisWorker.getAllImages(context);
            MediaDbHelper dbHelper = new MediaDbHelper(context);

            //Log.d("PhotoAnalysisProcess", "PhotoAnalysisProcess: Add photos info to database");
            PhotoAnalysisWorker.addPhotosInfoToDatabase(dbHelper, photos);

            mBuilder.setProgress(100, 5, false); // 5%
            notificationManager.notify(NotificationConstant.PHOTO_ANALYSIS_NOTIFICATION_ID, mBuilder.build());

            List<PhotoInfo> photosNeedAnalysis = dbHelper.getPhotosThatNeedAnalysis();

            //Log.d("PhotoAnalysisProcess", "PhotosNeedAnalysis: " + photosNeedAnalysis.size());

            PhotoScoreDetection photoScoreDetection = new PhotoScoreDetection(context);
            mm unknown = LowQualityPhotoDetection.m35303(photosNeedAnalysis);

            mBuilder.setProgress(100, 10, false); // 10%
            notificationManager.notify(NotificationConstant.PHOTO_ANALYSIS_NOTIFICATION_ID, mBuilder.build());

            //Log.d("PhotoAnalysisProcess", "PhotoAnalysisProcess: Analyze Photos -> Detect Low Quality Photos -> Update Database");

            // Bellow tasks will load from 10% to 90%

            int expectationMax = photosNeedAnalysis.size();
            int process = 0;

            int realityMax = (int) (expectationMax + (expectationMax * 0.1) + (expectationMax * 0.1));
            process += (expectationMax * 0.1); // loaded 10%

            for(PhotoInfo photoInfo : photosNeedAnalysis){
                PhotoAnalysisWorker.analyzePhotos(photoScoreDetection, photoInfo);
                LowQualityPhotoDetection.startDetection(context, unknown, photoInfo);
                updatePhotosInfoToDatabase(dbHelper, photoInfo);

                process++;

                mBuilder.setProgress(realityMax, process, false);
                notificationManager.notify(NotificationConstant.PHOTO_ANALYSIS_NOTIFICATION_ID, mBuilder.build());
            }

            mBuilder.setProgress(100, 90, false); // 90%
            notificationManager.notify(NotificationConstant.PHOTO_ANALYSIS_NOTIFICATION_ID, mBuilder.build());

            //Log.d("PhotoAnalysisProcess", "PhotoAnalysisProcess: Detecting Similar Photos");
            SimilarPhotoDataHandler similarPhotoDataHandler = new SimilarPhotoDataHandler(context);
            similarPhotoDataHandler.handleData();

            //Log.d("PhotoAnalysisProcess", "PhotoAnalysisProcess: End Analysis");

            mBuilder.setProgress(100, 100, false); // 100%
            notificationManager.notify(NotificationConstant.PHOTO_ANALYSIS_NOTIFICATION_ID, mBuilder.build());

        }catch (Exception e){
            //Log.d("PhotoAnalysisProcess", e.getMessage());
        } finally {
            PhotoAnalysisService.stopService(context);
        }

        return Result.success();
    }
    private static List<PhotoInfo> getAllImages(Context context){
        List<FileInfo> fileInfoList = FileManager.INSTANCE.getAllImages(context);
        List<PhotoInfo> listImages = new ArrayList<>();

        int k;
        for(k = 0; k < fileInfoList.size(); k++){
            FileInfo file = fileInfoList.get(k);
            try {
                ExifInterface exif = new ExifInterface(file.getPath());
                PhotoInfo PhotoInfo = new PhotoInfo(
                        file.getPath(),
                        0,
                        file.getCreatedDate(),
                        exif.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                                ExifInterface.ORIENTATION_UNDEFINED),
                        0.0,
                        0.0,0.0,0, 0, false, false, false);

                listImages.add(PhotoInfo);
            } catch (Throwable ignored) {
            }
        }
        return listImages;
    }

    private static void addPhotosInfoToDatabase(MediaDbHelper dbHelper, List<PhotoInfo> photos){
        for(PhotoInfo photo : photos){
            dbHelper.insertIfNotExists(photo);
        }
    }

    private static void analyzePhotos(PhotoScoreDetection photoScoreDetection, PhotoInfo photo){
        //Log.d("PhotoAnalysis", "Analyzing score" + photo.getPath());
        photoScoreDetection.calculatePhotoScore(photo);
        //Log.d("PhotoAnalysis", "Analyzing score SUCCESS " + photo.getPath());
    }

    private static void updatePhotosInfoToDatabase(MediaDbHelper dbHelper, PhotoInfo photo){
        dbHelper.updatePhotoAttributes(photo);
    }
}
