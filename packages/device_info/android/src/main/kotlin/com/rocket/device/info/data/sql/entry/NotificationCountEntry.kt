package com.rocket.device.info.data.sql.entry

import android.provider.BaseColumns

class NotificationCountEntry : BaseColumns {
    companion object {
        const val TABLE_NAME = "notification_count_db"
        const val COLUMN_NAME_PACKAGE_NAME = "package_name"
        const val COLUMN_NAME_NOTIFICATION_ID = "notification_id"
        const val COLUMN_NAME_POST_TIME = "post_time"
    }
}