package com.rocket.device.info.services

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.util.Log
import com.rocket.device.info.exception.AndroidRestrictionException
import com.rocket.device.info.models.FolderInfo
import java.io.File

class FolderInfoManager {
    //private val TAG: String = "FolderInfo"

    fun getThumbnails(): List<FolderInfo> {
        val path = Environment.getExternalStorageDirectory().toString()
        val listThumbnails = mutableListOf<FolderInfo>()
        val directory = File(path)
        val files = directory.listFiles()
        val thumbnailsName = ".thumbnails"

        if (!directory.canRead() || files == null) {
//            Log.d(
//                FolderInfoManager::class.java.name,
//                "Directory can't read or list files null (Thumbnails)"
//            )
            return listThumbnails
        }
        for (file in files) {
            if (!file.isDirectory) continue
            val foldersExistInFile = file.listFiles()
            for (folderExist in foldersExistInFile!!) {
                if (folderExist.isDirectory && folderExist.name.equals(thumbnailsName)) {
                    listThumbnails.add(
                        FolderInfo(
                            mapOf(
                                "name" to "${file.name}/$thumbnailsName",
                                "numberOfItems" to folderExist.list()!!.size,
                                "size" to getFolderSize(folderExist),
                                "path" to folderExist.path,
                            )
                        )
                    )
                }
            }
        }

        return listThumbnails
    }

    fun getFolderSize(dir: File): Long {
        var size: Long = 0
        val files = dir.listFiles()
        if (!dir.canRead() || files == null) {
//            Log.d(
//                FolderInfoManager::class.java.name,
//                "Directory can't read or list files null (Folder Size)"
//            )
            return 0
        }
        for (file in files) {
            size += if (file.isFile) {
                file.length()
            } else {
                getFolderSize(file)
            }
        }
        return size
    }

    fun addValueList(directory: File): List<FolderInfo> {
        val files = directory.listFiles()
        val listFolders = mutableListOf<FolderInfo>()

        if (!directory.canRead() || files == null) {
//            Log.d(
//                FolderInfoManager::class.java.name,
//                "Directory can't read or list files null"
//            )
            return listOf()
        }
        for (file in files) {
            if (!file.isDirectory) continue
            if (file.list()!!.isEmpty()) {
                listFolders.add(
                    FolderInfo(
                        mapOf(
                            "name" to file.name,
                            "numberOfItems" to file.list()!!.size,
                            "size" to file.length(),
                            "path" to file.path,
                        )
                    )
                )
            }
        }


        return listOf()
    }

    fun getEmptyFolders(context: Context): List<FolderInfo> {
        val path = Environment.getExternalStorageDirectory().toString()

        val listEmptyFolders = mutableListOf<FolderInfo>()
        val directory = File(path)
        val files = directory.listFiles()
        var test = File("")

        if (!directory.canRead() || files == null) {
//            throw Exception("Directory can't read or list files null")
            //Log.d(TAG, "Directory can't read or list files null")
            return listEmptyFolders
        }
        for (file in files) {
            if (file.isFile || file.list().isNotEmpty()) continue
            listEmptyFolders.add(
                FolderInfo(
                    mapOf(
                        "name" to file.name,
                        "numberOfItems" to file.list()!!.size,
                        "size" to getFolderSize(file),
                        "path" to file.path,
                    )
                )
            )
        }
        return listEmptyFolders
    }

    fun getVisibleCaches(): List<FolderInfo> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R){
            throw AndroidRestrictionException("Due to Android restrictions, this type of contents can only be shown on a computer.")
        }

        val path = Environment.getExternalStorageDirectory().toString() + "/Android/data"
        val listVisibleCache = mutableListOf<FolderInfo>()
        val directory = File(path)
        val files = directory.listFiles()
        val cacheName = "cache"

        if (!directory.canRead() || files == null) {
//            Log.d(
//                FolderInfoManager::class.java.name,
//                "Directory can't read or list files null (Visible cache)"
//            )
            listVisibleCache.add(
                FolderInfo(
                    mapOf(
                        "name" to "Temporary app files",
                        "numberOfItems" to 0,
                        "size" to 0,
                        "path" to path,
                    )
                )
            )
            return listVisibleCache
        }
        for (file in files) {
            if (!file.isDirectory) continue
            val foldersExistInFile = file.listFiles()
            if (!file.canRead() || foldersExistInFile == null) {
//                Log.d(
//                    FolderInfoManager::class.java.name,
//                    "Directory can't read or list files is null (Visible cache 1)"
//                )
                continue
            }
            for (folderExist in foldersExistInFile) {
                if (!folderExist.isDirectory || !folderExist.name.equals(cacheName)) continue
                listVisibleCache.add(
                    FolderInfo(
                        mapOf(
                            "name" to file.name,
                            "numberOfItems" to folderExist.list()!!.size,
                            "size" to getFolderSize(folderExist),
                            "path" to folderExist.path,
                        )
                    )
                )
            }
        }

        return listVisibleCache
    }

    fun getAllMediaFolders(mContext: Context): List<FolderInfo> {
        val fileInfoManager = FileInfoManager()
        val listPathAllMedia: MutableList<String> = ArrayList()
        val listAllMediaFolders = mutableListOf<FolderInfo>()

        for (media in fileInfoManager.getAllMediaFiles(mContext)) {

            listPathAllMedia.add(media.path.replace(media.name, ""))
        }

        cacheListPath = listPathAllMedia

        for (path in cacheListPath!!.distinct()) {
            val directory = File(path)

            listAllMediaFolders.add(
                FolderInfo(
                    mapOf(
                        "name" to directory.name,
                        "numberOfItems" to (directory.list()?.size ?: 0),
                        "size" to getFolderSize(directory),
                        "path" to directory.path,
                    )
                )
            )
        }

        return listAllMediaFolders
    }

    fun getIconFolderApp(context: Context, name: String): String {
        var packageName = "com.example.phone_cleaner"

        val time = System.currentTimeMillis()

        val packages = cacheIcon ?:
            context.packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        cacheIcon = packages

        val appInfoManager = AppInfoManager()
        for (app in packages) {
            if(app.flags and ApplicationInfo.FLAG_SYSTEM != 0) continue
            if (!name.contains(context.packageManager.getApplicationLabel(app))) continue
            packageName = app.packageName
        }

        //Log.d(TAG, "${System.currentTimeMillis() - time}")

        return ""
    }

    fun getAppData(): List<FolderInfo> {
        val path = Environment.getExternalStorageDirectory().toString() + "/Pictures"
        val listAppData = mutableListOf<FolderInfo>()
        val files = File(path).listFiles() ?: return listAppData

        for (file in files) {
            if (file.isFile || file.name.contains(".") || file.name.contains("RocketCleaner")) continue
            if (file.list().isEmpty()) continue

            listAppData.add(
                FolderInfo(
                    mapOf(
                        "name" to file.name,
                        "numberOfItems" to file.list().size,
                        "size" to getFolderSize(file),
                        "path" to file.path,
                    )
                )
            )

        }

        return listAppData
    }


    companion object {
        var cacheIcon : MutableList<ApplicationInfo>? = null
        var cacheListPath : MutableList<String>? = null
        var cacheAllFolder : MutableList<FolderInfo>? = null
    }

}