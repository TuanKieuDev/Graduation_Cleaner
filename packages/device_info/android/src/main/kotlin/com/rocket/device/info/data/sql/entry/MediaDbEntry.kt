package com.rocket.device.info.data.sql.entry

import android.provider.BaseColumns

class MediaDbEntry : BaseColumns {
    companion object {
        const val TABLE_NAME = "media_db"
        const val COLUMN_NAME_PATH = "path"
        const val COLUMN_NAME_ANDROID_ID = "android_id"
        const val COLUMN_NAME_DATE_TAKEN = "date_taken"
        const val COLUMN_NAME_ORIENTATION = "orientation"
        const val COLUMN_NAME_BLURRY = "blurry"
        const val COLUMN_NAME_COLOR = "color"
        const val COLUMN_NAME_DARK = "dark"
        const val COLUMN_NAME_FACES_COUNT = "facesCount"
        const val COLUMN_NAME_SCORE = "score"
        const val COLUMN_NAME_CV_ANALYZED = "cvAnalyzed"
        const val COLUMN_NAME_WAS_ANALYZED_FOR_BAD_PHOTO = "wasAnalyzedForBadPhoto"
        const val COLUMN_NAME_IS_BAD_PHOTO = "isBad"
    }
}