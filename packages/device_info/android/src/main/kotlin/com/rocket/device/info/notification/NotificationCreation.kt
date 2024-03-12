package com.rocket.device.info.notification

import android.R
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat
import com.rocket.device.info.services.getTimeRemainingForBatteryAnalysis

object NotificationCreation {

    fun createPhotoAnalysisNotificationBuilder(context: Context) : NotificationCompat.Builder{
        val channelId = createNotificationChannel(context, "photo_analysis_channel_id", "Photo Analysis Service")
        val contentTitle = "Photo Analysis Service is running"
        val contentText = "Service is running..."
        val pendingIntent = createPendingIntentThatLinkWithFlutterNotificationLibrary(context, NotificationConstant.PHOTO_ANALYSIS_NOTIFICATION_ID, "photo_analysis")

        val notification = NotificationInfo(NotificationConstant.PHOTO_ANALYSIS_NOTIFICATION_ID, channelId,contentTitle, contentText)

        notification.pendingIntent = pendingIntent
        notification.onGoing = true
        notification.smallIcon = R.drawable.sym_def_app_icon

        val builder = createNotificationBuilder(context, notification)

        builder.setProgress(0,0,true)

        return builder
    }
    fun createBatteryAnalysisNotificationBuilder(context: Context) : NotificationCompat.Builder{
        val channelId = createNotificationChannel(context, "battery_analysis_channel_id", "Battery Analysis Service")
        val contentTitle = "Battery monitoring is running"
        var contentText = "Click to show the result"
        var pendingIntent : PendingIntent? = createPendingIntentThatLinkWithFlutterNotificationLibrary(context, NotificationConstant.BATTERY_ANALYSIS_NOTIFICATION_ID, "battery_analysis")

        val timeRemainingForAnalysis = context.getTimeRemainingForBatteryAnalysis();
        if(timeRemainingForAnalysis > 0){
            contentText = "Please wait until analysis is ready"
            pendingIntent = null
        }

        val batteryAnalysisNotification = NotificationInfo(NotificationConstant.BATTERY_ANALYSIS_NOTIFICATION_ID, channelId,contentTitle, contentText)

        batteryAnalysisNotification.pendingIntent = pendingIntent
        batteryAnalysisNotification.onGoing = true
        batteryAnalysisNotification.smallIcon = R.drawable.sym_def_app_icon

        return createNotificationBuilder(context, batteryAnalysisNotification)
    }

    private fun createNotificationBuilder(context: Context, notificationInfo : NotificationInfo): NotificationCompat.Builder{
        val notificationBuilder = NotificationCompat.Builder(context, notificationInfo.channelId)
            .setContentTitle(notificationInfo.contentTitle)
            .setContentText(notificationInfo.contentText)
            .setOngoing(notificationInfo.onGoing)

        if(notificationInfo.pendingIntent != null){
            notificationBuilder.setContentIntent(notificationInfo.pendingIntent)
        }

        if(notificationInfo.largeIcon != null){
            notificationBuilder.setLargeIcon(notificationInfo.largeIcon)
        }

        if(notificationInfo.smallIcon != 0){
            notificationBuilder.setSmallIcon(notificationInfo.smallIcon)
        }

        return notificationBuilder
    }

    private fun createNotificationChannel(context: Context, channelId: String, channelName: String): String{
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            val chan = NotificationChannel(channelId,
                channelName, NotificationManager.IMPORTANCE_NONE)
            chan.lightColor = Color.BLUE
            chan.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
            val service = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            service.createNotificationChannel(chan)
            return channelId
        }
        return ""
    }

    private fun createPendingIntentThatLinkWithFlutterNotificationLibrary(context: Context, notificationId: Int, payload: String) : PendingIntent{
        val intent: Intent? = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.action = "SELECT_NOTIFICATION"
        intent?.putExtra("notificationId", notificationId)
        intent?.putExtra("payload", payload)
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        return PendingIntent.getActivity(context, notificationId, intent, flags)
    }
}