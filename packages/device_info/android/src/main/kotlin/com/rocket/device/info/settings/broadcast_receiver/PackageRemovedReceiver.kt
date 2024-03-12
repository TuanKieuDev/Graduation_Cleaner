package com.rocket.device.info.settings.broadcast_receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class PackageRemovedReceiver : BroadcastReceiver {

    private var context : Context

    private var flutterMethodChannel : MethodChannel

    private var intentFilter: IntentFilter
    private var isRunning = false

    constructor(context: Context, flutterMethodChannel : MethodChannel){
        this.context = context

        this.flutterMethodChannel = flutterMethodChannel

        val intentFilter = IntentFilter()
        intentFilter.addAction(Intent.ACTION_PACKAGE_REMOVED)
        intentFilter.addDataScheme("package")

        this.intentFilter = intentFilter
    }

    override fun onReceive(context: Context, intent: Intent) {

        if( isOrderedBroadcast ) {
            return
        }

        val packageName = intent.data!!.schemeSpecificPart

        if (intent.action == Intent.ACTION_PACKAGE_REMOVED && packageName != null) {
            flutterMethodChannel.invokeMethod("onPackageRemovedReceive", packageName)
        }
    }

    fun registerReceiver() {
        if (!this.isRunning) {
            //Log.d("PackageRemovedReceiver", "Package Removed Receiver registered!")
            context.registerReceiver(this, this.intentFilter)
            this.isRunning = true
        }
    }

    fun unregisterReceiver() {
        if (this.isRunning) {
            //Log.d("PackageRemovedReceiver", "Package Removed Receiver unregistered!")
            context.unregisterReceiver(this)
            this.isRunning = false
        }
    }
}