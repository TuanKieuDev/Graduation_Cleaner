package com.rocket.device.info.data.sql.entry

import android.provider.BaseColumns

class BatteryAnalysisEntry : BaseColumns {
    companion object {
        const val TABLE_NAME = "battery_analysis_db"
        const val COLUMN_NAME_TIME_STAMP = "time_stamp"
        const val COLUMN_NAME_BATTERY_LEVEL = "battery_level"
        const val COLUMN_NAME_IS_CHARGING = "is_charging"
    }
}