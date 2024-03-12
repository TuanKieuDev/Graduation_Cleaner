package com.rocket.device.info.models

import com.google.gson.Gson

class AppInfoUsage() {
    var packageName: String = ""
    var totalTimeSpent: Long = 0
    var totalDataUsage:Long = 0
    var totalOpened:Long = 0
    var listUsage: List<Map<Long, Long>> = mutableListOf<Map<Long, Long>>().toList()

    constructor(str: String, j2: Long, i: Int) : this() {
        this.packageName = str
        this.totalTimeSpent = j2
        this.totalOpened = i.toLong()
    }

    override fun toString(): String {
        val gson = Gson()

        return gson.toJson(hashMapOf(
            "packageName" to packageName,
            "totalTimeSpent" to totalTimeSpent,
            "totalDataUsage" to totalDataUsage,
            "totalOpened" to totalOpened,
            "listUsage" to listUsage,
        ))
    }
}

