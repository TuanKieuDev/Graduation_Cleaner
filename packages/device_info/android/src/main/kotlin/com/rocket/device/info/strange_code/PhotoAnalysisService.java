package com.rocket.device.info.strange_code;

import android.app.Notification;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import com.rocket.device.info.notification.NotificationConstant;
import com.rocket.device.info.notification.NotificationCreation;
import com.rocket.device.info.settings.Permissions;

public class PhotoAnalysisService extends Service {

    public static boolean isRunning = false;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        Notification notification = NotificationCreation.INSTANCE.createPhotoAnalysisNotificationBuilder(this).build();

        startForeground(NotificationConstant.PHOTO_ANALYSIS_NOTIFICATION_ID, notification);

        return START_STICKY;
    }

    public static void startService(Context context){

        boolean isEnable = Permissions.INSTANCE.isNotificationPermissionGranted(context);

        if(isEnable){
            if(!PhotoAnalysisService.isRunning){
                Intent intent = new Intent(context, PhotoAnalysisService.class);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent);
                }else{
                    context.startService(intent);
                }

                PhotoAnalysisWorker.startAnalysis(context);

                PhotoAnalysisService.isRunning = true;
            }
        }else{
            if(PhotoAnalysisService.isRunning){
                stopService(context);
            }
        }
    }

    public static void stopService(Context context){
        Intent intent = new Intent(context, PhotoAnalysisService.class);
        context.stopService(intent);
        PhotoAnalysisService.isRunning = false;
    }
}
