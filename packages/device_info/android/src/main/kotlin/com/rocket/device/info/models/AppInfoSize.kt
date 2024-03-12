package com.rocket.device.info.models

class AppInfoSize(
    val packageName: String,
    val appSize: Long,
    val dataSize: Long,
    val cacheSize: Long
    )
{
    fun toMap(): Map<String, Any> {
        val map = HashMap<String, Any>()
        map.put("packageName", packageName)
        map.put("appSize", appSize)
        map.put("dataSize", dataSize)
        map.put("cacheSize", cacheSize)
        return map;
    }

    fun getTotalSize() : Long{
        return appSize + dataSize + cacheSize
    }
}
