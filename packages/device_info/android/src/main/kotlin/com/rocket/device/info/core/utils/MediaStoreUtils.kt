package com.rocket.device.info.core.utils

import android.content.ContentUris
import android.net.Uri
import android.provider.MediaStore

object MediaStoreUtils {
    private fun getInsertUri(mediaType: Int): Uri {
        return when (mediaType) {
            MediaStore.Files.FileColumns.MEDIA_TYPE_AUDIO -> MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            else -> IDBUtils.allUri
        }
    }

    fun getUri(id: Long, mediaType: Int): Uri {
        return ContentUris.withAppendedId(getInsertUri(mediaType), id)
    }

    fun convertTypeToMediaType(type: Int): Int {
        return when (type) {
            1 -> MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE
            2 -> MediaStore.Files.FileColumns.MEDIA_TYPE_AUDIO
            3 -> MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO
            else -> 0
        }
    }
}