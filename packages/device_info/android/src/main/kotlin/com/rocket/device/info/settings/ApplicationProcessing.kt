package com.rocket.device.info.settings

import android.content.pm.ApplicationInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import java.io.ByteArrayOutputStream

fun Drawable.toBitmap(): Bitmap{
    if (this is BitmapDrawable && this.bitmap != null){
        return this.bitmap
    }

    val bitmap: Bitmap = if (this.intrinsicWidth <= 0 || this.intrinsicHeight <= 0) {
        Bitmap.createBitmap(
            50,
            50,
            Bitmap.Config.ARGB_8888
        )
    } else {
        Bitmap.createBitmap(
            this.intrinsicWidth,
            this.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
    }
    val canvas = Canvas(bitmap)
    this.setBounds(0, 0, canvas.width, canvas.height)
    this.draw(canvas)
    return bitmap
}

fun Bitmap.encodeToString(): String{
    val outputStream = ByteArrayOutputStream()
    this.compress(Bitmap.CompressFormat.PNG, 5, outputStream)
    return Base64.encodeToString(outputStream.toByteArray(), Base64.DEFAULT)
}

fun Bitmap.toByteArray(): ByteArray {
    val outputStream = ByteArrayOutputStream()
    this.compress(Bitmap.CompressFormat.PNG, 5, outputStream)
    val byteArray = outputStream.toByteArray()
    outputStream.close()

    return byteArray
}

fun ApplicationInfo.isSystem(): Boolean {
    return this.flags and ApplicationInfo.FLAG_SYSTEM != 0
}

fun ApplicationInfo.isStopped(): Boolean {
    return this.flags and ApplicationInfo.FLAG_STOPPED != 0
}