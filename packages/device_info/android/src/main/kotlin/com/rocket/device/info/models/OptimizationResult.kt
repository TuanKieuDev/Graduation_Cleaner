package com.rocket.device.info.models

data class OptimizationResult(
    val originalPhotoWithNewPath: FileInfo?,
    val optimizedPhoto: FileInfo,
    val savedSpaceInBytes: Long,
){
    fun toMap(): Map<String, Any?>{
        return mapOf(
            "optimizedPhoto" to optimizedPhoto.toMap(),
            "originalPhotoWithNewPath" to originalPhotoWithNewPath?.toMap(),
            "savedSpaceInBytes" to savedSpaceInBytes
        )
    }
}
