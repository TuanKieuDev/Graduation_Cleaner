package com.rocket.device.info.models

data class PhotoOptimizationResult(
    val beforeSize: Long,
    val afterSize: Long,
    val optimizedImage: ByteArray,
) {
    fun toMap(): Map<String, Any>{
        return mapOf(
            "beforeSize" to beforeSize,
            "afterSize" to afterSize,
            "optimizedImage" to optimizedImage
        )
    }
}