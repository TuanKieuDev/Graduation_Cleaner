package com.rocket.device.info.services

import android.app.Notification
import android.content.Context
import android.content.Intent
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import com.rocket.device.info.data.sql.helper.NotificationCountDbHelper

class NotificationService : NotificationListenerService() {
    private lateinit var context: Context

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onCreate() {
        super.onCreate()
        context = applicationContext
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {

        //Log.d("NotificationCount", "PackageName: ${sbn.packageName} --- Flags: ${sbn.notification.flags}")

        addNotificationsToDatabase(arrayOf(sbn))
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        addNotificationsToDatabase(activeNotifications)
    }

    private fun addNotificationsToDatabase(notifications: Array<StatusBarNotification>){
        val databaseHandler = NotificationCountDbHelper(context)

        for (notification in notifications) {

            val shouldAddNotification = shouldAddNotificationToDatabase(notification)

            if(shouldAddNotification){
                databaseHandler.addNotificationInfo(notification)
            }
        }

        databaseHandler.close()
    }

    private fun shouldAddNotificationToDatabase(notification: StatusBarNotification) : Boolean{
        val appPackageName = packageName
        val notificationPackageName = notification.packageName

        if(appPackageName == notificationPackageName){
            return false
        }

        val notificationFlags = notification.notification.flags

        if(notificationFlags and Notification.FLAG_FOREGROUND_SERVICE != 0){
            return false
        }

        if(notificationFlags and Notification.FLAG_ONGOING_EVENT != 0){
            return false
        }

        val isInstalledApplication = context.isInstalledApplication(notificationPackageName)

        if(!isInstalledApplication){
            return false
        }

        return true
    }
}