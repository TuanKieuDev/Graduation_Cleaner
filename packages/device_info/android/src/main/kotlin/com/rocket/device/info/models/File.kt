package com.rocket.device.info.models

data class File (
    val name: String,
    val path: String,
    val size: Long,
    val extension: String,
    val lastModifiedInMilli: Long,
){
    fun toMap(): Map<String, Any>{
        return mapOf(
            "name" to name,
            "path" to path,
            "size" to size,
            "extension" to extension,
            "lastModifiedInMillis" to lastModifiedInMilli
        )
    }
}