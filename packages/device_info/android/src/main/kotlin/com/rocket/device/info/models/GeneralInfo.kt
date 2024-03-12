package com.rocket.device.info.models

import org.json.JSONObject

class GeneralInfo(val generalInfo: Map<String, Any>) {
    val usedSpace:Int by generalInfo
    val totalSpace:Int by generalInfo
    val usedMemory:Int by generalInfo
    val totalMemory:Int by generalInfo
    val freeMemory:Int by generalInfo
    val battery:Int by generalInfo

    override fun toString(): String {
        return "${JSONObject(generalInfo)}"
    }
}

