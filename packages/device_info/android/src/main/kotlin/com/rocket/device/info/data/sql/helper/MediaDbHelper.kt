package com.rocket.device.info.data.sql.helper

import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import com.rocket.device.info.strange_code.PhotoInfo
import com.rocket.device.info.data.sql.config.MediaDbConfig
import com.rocket.device.info.data.sql.entry.MediaDbEntry
import java.io.File

class MediaDbHelper(context: Context) : SQLiteOpenHelper(context, MediaDbConfig.DATABASE_NAME, null, MediaDbConfig.DATABASE_VERSION) {

    private val SQL_CREATE_ENTRIES =
        "CREATE TABLE " + MediaDbEntry.TABLE_NAME + " (" +
                MediaDbEntry.COLUMN_NAME_PATH + " TEXT PRIMARY KEY, " +
                MediaDbEntry.COLUMN_NAME_ANDROID_ID + " INTEGER," +
                MediaDbEntry.COLUMN_NAME_DATE_TAKEN + " INTEGER," +
                MediaDbEntry.COLUMN_NAME_ORIENTATION + " INTEGER," +
                MediaDbEntry.COLUMN_NAME_BLURRY + " REAL," +
                MediaDbEntry.COLUMN_NAME_COLOR + " REAL," +
                MediaDbEntry.COLUMN_NAME_DARK + " REAL," +
                MediaDbEntry.COLUMN_NAME_FACES_COUNT + " INTEGER," +
                MediaDbEntry.COLUMN_NAME_SCORE + " REAL," +
                MediaDbEntry.COLUMN_NAME_CV_ANALYZED + " INTEGER," +
                MediaDbEntry.COLUMN_NAME_WAS_ANALYZED_FOR_BAD_PHOTO + " INTEGER," +
                MediaDbEntry.COLUMN_NAME_IS_BAD_PHOTO + " INTEGER)"

    override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL(SQL_CREATE_ENTRIES)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        //onCreate(db)
    }

    override fun onDowngrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        onUpgrade(db, oldVersion, newVersion)
    }

    fun getPhotoInfoFromCursor(cursor: Cursor) : PhotoInfo{
        val path = cursor.getString(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_PATH))
        val androidId = cursor.getLong(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_ANDROID_ID))
        val dateTaken = cursor.getLong(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_DATE_TAKEN))
        val orientation = cursor.getInt(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_ORIENTATION))
        val blurry = cursor.getDouble(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_BLURRY))
        val color = cursor.getDouble(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_COLOR))
        val dark = cursor.getDouble(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_DARK))
        val facesCount = cursor.getInt(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_FACES_COUNT))
        val score = cursor.getDouble(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_SCORE))
        val cvAnalyzed = cursor.getInt(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_CV_ANALYZED))
        val wasAnalyzedForBadPhoto = cursor.getInt(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_WAS_ANALYZED_FOR_BAD_PHOTO))
        val isBad = cursor.getInt(cursor.getColumnIndexOrThrow(MediaDbEntry.COLUMN_NAME_IS_BAD_PHOTO))

        return PhotoInfo(path, androidId, dateTaken, orientation, blurry, color, dark, facesCount, score,
            cvAnalyzed == 1, wasAnalyzedForBadPhoto == 1, isBad == 1)
    }

    fun insertIfNotExists(photoInfo : PhotoInfo){
        val db = writableDatabase

        val values = ContentValues()
        values.put(MediaDbEntry.COLUMN_NAME_PATH, photoInfo.path)
        values.put(MediaDbEntry.COLUMN_NAME_ANDROID_ID, photoInfo.androidId)
        values.put(MediaDbEntry.COLUMN_NAME_DATE_TAKEN, photoInfo.dateTaken)
        values.put(MediaDbEntry.COLUMN_NAME_ORIENTATION, photoInfo.orientation)
        values.put(MediaDbEntry.COLUMN_NAME_BLURRY, photoInfo.blurry)
        values.put(MediaDbEntry.COLUMN_NAME_COLOR, photoInfo.color)
        values.put(MediaDbEntry.COLUMN_NAME_DARK, photoInfo.dark)
        values.put(MediaDbEntry.COLUMN_NAME_FACES_COUNT, photoInfo.facesCount)
        values.put(MediaDbEntry.COLUMN_NAME_SCORE, photoInfo.score)
        values.put(MediaDbEntry.COLUMN_NAME_CV_ANALYZED, if (photoInfo.isCVAnalyzed) 1 else 0)
        values.put(MediaDbEntry.COLUMN_NAME_WAS_ANALYZED_FOR_BAD_PHOTO, if (photoInfo.isWasAnalyzedForBadPhoto) 1 else 0)
        values.put(MediaDbEntry.COLUMN_NAME_IS_BAD_PHOTO, if (photoInfo.isBadPhoto) 1 else 0)

        db.insertWithOnConflict(MediaDbEntry.TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_IGNORE)

        db.close()
    }

    fun updatePhotoInfoByPath(path: String, values: ContentValues){
        val whereClause = MediaDbEntry.COLUMN_NAME_PATH + " = ?"
        val whereArgs = arrayOf(path)

        val db = writableDatabase
        db.update(MediaDbEntry.TABLE_NAME, values, whereClause, whereArgs)
        db.close()
    }

    fun updatePhotoAttributes(photoInfo: PhotoInfo){

        val values = ContentValues()
        values.put(MediaDbEntry.COLUMN_NAME_BLURRY, photoInfo.blurry)
        values.put(MediaDbEntry.COLUMN_NAME_COLOR, photoInfo.color)
        values.put(MediaDbEntry.COLUMN_NAME_DARK, photoInfo.dark)
        values.put(MediaDbEntry.COLUMN_NAME_FACES_COUNT, photoInfo.facesCount)
        values.put(MediaDbEntry.COLUMN_NAME_SCORE, photoInfo.score)
        values.put(MediaDbEntry.COLUMN_NAME_CV_ANALYZED, if (photoInfo.isCVAnalyzed) 1 else 0)

        updatePhotoInfoByPath(photoInfo.path, values);
    }

    private fun deletePhotoInfo(photoInfo: PhotoInfo){
        val db = writableDatabase

        val whereClause = MediaDbEntry.COLUMN_NAME_PATH + " = ?"
        val whereArgs = arrayOf(photoInfo.path)

        db.delete(MediaDbEntry.TABLE_NAME, whereClause, whereArgs)
        db.close()
    }

    fun getPhotosFromDatabase(selection: String?, selectionArgs: Array<String>?) : List<PhotoInfo> {
        val photosInfo = mutableListOf<PhotoInfo>()

        val db = readableDatabase

        val projection = arrayOf("*")

        val cursor: Cursor = db.query(
            MediaDbEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
        )

        while (cursor.moveToNext()) {
            val photoInfo = getPhotoInfoFromCursor(cursor)

            if(!File(photoInfo.path).exists()){
                deletePhotoInfo(photoInfo)
            }else{
                photosInfo.add(photoInfo)
            }
        }

        cursor.close()
        db.close()

        return photosInfo
    }

    fun getPhotosThatNeedAnalysis() : List<PhotoInfo> {
        val selection = MediaDbEntry.COLUMN_NAME_CV_ANALYZED + " = ?"
        val selectionArgs = arrayOf("0")

        return getPhotosFromDatabase(selection, selectionArgs)
    }

    fun getPhotosThatNeedAnalysisForBadPhoto() : List<PhotoInfo> {
        val photosInfo = mutableListOf<PhotoInfo>()

        val db = readableDatabase

        val projection = arrayOf("*")
        val selection = MediaDbEntry.COLUMN_NAME_WAS_ANALYZED_FOR_BAD_PHOTO + " = ?"
        val selectionArgs = arrayOf("0")

        val cursor: Cursor = db.query(
            MediaDbEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
        )

        while (cursor.moveToNext()) {
            val photoInfo = getPhotoInfoFromCursor(cursor);
            photosInfo.add(photoInfo)
        }

        cursor.close()
        db.close()

        return photosInfo
    }

    fun getPathsOfBadPhoto() : List<String>{
        val paths = mutableListOf<String>()
        val db = readableDatabase

        val projection = arrayOf("*")
        val selection = MediaDbEntry.COLUMN_NAME_IS_BAD_PHOTO + " = ?"
        val selectionArgs = arrayOf("1")

        val cursor: Cursor = db.query(
            MediaDbEntry.TABLE_NAME,
            projection,
            selection,
            selectionArgs,
            null,
            null,
            null
        )

        while (cursor.moveToNext()) {
            val photoInfo = getPhotoInfoFromCursor(cursor)
            val pathPhoto = photoInfo.path
            if(File(pathPhoto).exists()){
                paths.add(pathPhoto)
            }else{
                deletePhotoInfo(photoInfo)
            }
        }

        cursor.close()
        db.close()
        return paths
    }
}