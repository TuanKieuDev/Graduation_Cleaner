package com.rocket.device.info.models

data class Folder(
    val name: String,
    val itemCount: Int,
    val sizeInBytes: Long,
    val path: String
){
    fun toMap(): Map<String, Any>{
        return mapOf(
            "name" to name,
            "itemCount" to itemCount,
            "path" to path,
            "sizeInBytes" to sizeInBytes,
        )
    }
}
