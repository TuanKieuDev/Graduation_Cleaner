package com.rocket.device.info.models

import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.MediaStore
import org.json.JSONObject
import java.util.*

class FileInfo(val fileInfo: Map<String, Any?>) {
    val mediaId : Long = fileInfo["mediaId"] as? Long ?: 0L
    val mediaType : Int = fileInfo["mediaType"] as? Int ?: 0
    val idFolder: String by fileInfo
    val name: String by fileInfo
    val size: Int by fileInfo
    val extensionFile: String by fileInfo
    val path: String by fileInfo
    val timeModified: Long by fileInfo
    val createdDate: Long by fileInfo

    override fun toString(): String {
        return "${JSONObject(fileInfo)}"
    }

    fun toMap() : Map<String, Any> {
        return mutableMapOf(
            "mediaId" to mediaId,
            "mediaType" to mediaType,
            "idFolder" to idFolder,
            "name" to name,
            "size" to size,
            "extension" to extensionFile,
            "path" to path,
            "lastModified" to timeModified,
        )
    }

    companion object {
        fun getMediaIdFromPath(context: Context, filePath: String): Long {
            val uri: Uri = MediaStore.Files.getContentUri("external")
            val projection = arrayOf(MediaStore.Files.FileColumns._ID)
            val selection: String = MediaStore.Files.FileColumns.DATA + "=?"
            val selectionArgs = arrayOf(filePath)
            val cursor: Cursor? =
                context.contentResolver.query(uri, projection, selection, selectionArgs, null)
            if (cursor != null && cursor.moveToFirst()) {
                val idColumnIndex: Int = cursor.getColumnIndex(MediaStore.Files.FileColumns._ID)
                val id: Long = cursor.getLong(idColumnIndex)
                cursor.close()
                return id
            }
            return -1
        }
    }
}


