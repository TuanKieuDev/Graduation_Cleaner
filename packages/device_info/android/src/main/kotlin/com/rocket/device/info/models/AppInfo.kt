package com.rocket.device.info.models

import com.google.gson.Gson

class AppInfo(val appInfo: HashMap<String, Any>) {
    val name:String by appInfo
    val iconApp:String by appInfo
    val version:String by appInfo
    val packageName: String by appInfo
    val type: AppType by appInfo
    val timeNotificationSent : Int by appInfo
    val appSize: Int by appInfo
    val dataSize: Int by appInfo
    val cacheSize: Int by appInfo
    val totalSizeApp : Long by appInfo

    override fun toString(): String {
        val gson = Gson()
        return gson.toJson(appInfo)
    }
}



