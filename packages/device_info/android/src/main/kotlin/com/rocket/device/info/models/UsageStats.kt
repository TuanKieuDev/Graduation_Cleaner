package com.app.cleaner.device.info.library.models

data class UsageStats(
    val packageName: String,
    val lastUsedEpochTime: Long,
    val lastEpochTimeForegroundServiceUsed: Long?,
    val totalMillisecondsInForeground: Long,
    val totalMillisecondsVisible: Long?,
)
