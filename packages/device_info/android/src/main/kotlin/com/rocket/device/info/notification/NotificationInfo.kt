package com.rocket.device.info.notification

import android.app.PendingIntent
import android.graphics.Bitmap

class NotificationInfo(
    var notificationId: Int,
    var channelId: String,
    var contentTitle: String,
    var contentText: String,
) {
    var onGoing = false
    var pendingIntent: PendingIntent? = null
    var smallIcon : Int = 0
    var largeIcon : Bitmap? = null
}