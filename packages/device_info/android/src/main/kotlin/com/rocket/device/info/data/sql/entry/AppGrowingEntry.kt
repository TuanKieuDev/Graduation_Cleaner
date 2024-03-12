package com.rocket.device.info.data.sql.entry

import android.provider.BaseColumns

class AppGrowingEntry : BaseColumns {
    companion object {
        const val TABLE_NAME = "app_growing"
        const val COLUMN_NAME_PACKAGE_NAME = "package_name"
        const val COLUMN_NAME_SIZE = "size"
        const val COLUMN_NAME_DATE = "date"
    }
}