package com.rocket.device.info.models

import org.json.JSONObject

class FolderInfo(private val folderInfo: Map<String, Any>) {
    val name: String by folderInfo
    val numberOfItems: Int by folderInfo
    val size: Int by folderInfo
    val path: String by folderInfo

    override fun toString(): String {
        return "${JSONObject(folderInfo)}"
    }
}

