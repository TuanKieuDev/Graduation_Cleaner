package com.rocket.device.info.device

import android.app.Activity
import android.content.Context
import android.os.Build
import android.util.DisplayMetrics
import android.util.Size
import android.view.WindowManager
import android.view.WindowMetrics


object DeviceParams {

    fun getScreenSize(context: Context) : Size{
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val metrics: WindowMetrics = context.getSystemService(WindowManager::class.java).currentWindowMetrics
            return Size(metrics.bounds.width(), metrics.bounds.height())
        } else {
            val display = context.resources.displayMetrics

            val height = display.heightPixels
            val width = display.widthPixels

            return Size(width, height)
        }
    }
}