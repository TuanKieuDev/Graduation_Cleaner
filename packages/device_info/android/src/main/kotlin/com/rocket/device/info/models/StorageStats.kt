package com.app.cleaner.device.info.library.models

data class StorageStats(
    val packageName: String,
    val appSize: Long,
    val dataSize: Long,
    val cacheSize: Long,
    val externalCacheBytes: Long?
)
