package com.rocket.device.info.models

data class PackageInfo(
    val packageName: String,
    val appType: String,
    val flags: Int,
    val category: Int,
    val permissions: String?,
    val storageUUID: String?,
    val uid: Int,
){
    fun toMap(): Map<String, Any> {
        val map = HashMap<String, Any>()
        map["packageName"] = packageName
        map["appType"] = appType
        map["flags"] = flags
        map["category"] = category
        if(permissions != null) map["permissions"] = permissions
        if(storageUUID != null) map["storageUUID"] = storageUUID
        map["uid"] = uid
        return map
    }
}
