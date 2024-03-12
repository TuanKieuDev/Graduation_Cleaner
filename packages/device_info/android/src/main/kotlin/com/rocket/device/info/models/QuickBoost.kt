package com.rocket.device.info.models

import com.google.gson.Gson

class QuickBoost(
    val beforeRam: Long,
    val afterRam: Long,
    val ramOptimized: Long
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            "beforeRam" to beforeRam,
            "afterRam" to afterRam,
            "ramOptimized" to ramOptimized,
        )
    }

    override fun toString(): String {
        val gson = Gson()
        return gson.toJson(this.toMap())
    }
}