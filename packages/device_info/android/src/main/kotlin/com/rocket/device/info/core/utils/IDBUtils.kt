package com.rocket.device.info.core.utils

import android.net.Uri
import android.provider.MediaStore

interface IDBUtils {
    companion object {
        val allUri: Uri
            get() = MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL)
    }

    val allUri: Uri
        get() = IDBUtils.allUri
}