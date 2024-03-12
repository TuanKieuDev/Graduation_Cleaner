package com.rocket.device.info.services

import android.Manifest.permission.READ_EXTERNAL_STORAGE
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build.VERSION.SDK_INT
import android.os.Build.VERSION_CODES
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.database.getStringOrNull
import androidx.work.*
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.rocket.device.info.core.StorageConstant
import com.rocket.device.info.data.LocalStorage
import com.rocket.device.info.data.sql.helper.MediaDbHelper
import com.rocket.device.info.exception.AndroidRestrictionException
import com.rocket.device.info.exception.PermissionException
import com.rocket.device.info.models.FileInfo
import com.rocket.device.info.models.Folder
import com.rocket.device.info.models.OptimizationResult
import com.rocket.device.info.settings.*
import com.rocket.device.info.settings.ImageProcessing
import com.rocket.device.info.settings.Permissions
import com.rocket.device.info.util.ResultHandler
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import com.rocket.device.info.strange_code.PhotoAnalysisService
import java.io.File
import java.io.FileFilter
import java.io.IOException
import java.lang.reflect.Type
import java.nio.file.Files
import java.util.*


object FileManager {

    private const val thumbnailsFolderName = ".thumbnails"

    fun getThumbnails(context: Context): List<Folder> {
        if (!Permissions.isStoragePermissionGranted(context)) {
            throw PermissionException("Read Environment.getExternalStorageDirectory() for more information on the required permissions.")
        }

        val directory = Environment.getExternalStorageDirectory()

        val directoryFilter = FileFilter { it.isDirectory }

        val dirs: Queue<File> = LinkedList()
        dirs.add(directory)

        val thumbnails = mutableListOf<Folder>()

        while (dirs.isNotEmpty()) {
            val dir = dirs.poll()!!
            if (!dir.isDirectory)
                continue

            if (dir.name != thumbnailsFolderName) {
                dir.listFiles(directoryFilter)?.let { dirs.addAll(it) }
                continue
            }

            thumbnails.add(
                Folder(
                    "${dir.name}/$thumbnailsFolderName",
                    countItems(dir),
                    getFolderSize(dir),
                    dir.path,
                )
            )
        }

        return thumbnails
    }

    fun getEmptyFolders(context: Context): List<Folder> {
        val dir = context.getExternalFilesDir(null)!!
        //android.util.Log.d("FileManager", dir.path)

        if (!dir.canRead()) {
            throw PermissionException("Read Environment.getExternalStorageDirectory() for more information on the required permissions.")
        }

        val dirs: Queue<File> = LinkedList()
        dirs.add(dir)

        val emptyFolders = mutableListOf<Folder>()

        while (dirs.isNotEmpty()) {
            val dir = dirs.poll()!!

            if (!dir.exists())
                continue

            if (dir.isFile)
                continue

            if (!isDirEmpty(dir)) {
                val subDirs = dir.listFiles()
                if (subDirs == null || subDirs.isEmpty())
                    continue

                dirs.addAll(subDirs)
                continue
            }

            emptyFolders.add(
                Folder(
                    dir.name,
                    0,
                    dir.length(),
                    dir.path
                )
            )
        }

        return emptyFolders
    }

    fun getVisibleCaches(context: Context): List<Folder> {
        if (SDK_INT >= VERSION_CODES.R) {
            throw AndroidRestrictionException("Due to Android restrictions, this type of contents can only be shown on a computer.")
        }

        val path = context.getExternalFilesDir(null)!!.toString() + "/Android/data"
        val listVisibleCache = mutableListOf<Folder>()
        val directory = File(path)
        val files = directory.listFiles()

        if (!directory.canRead() || files == null) {
            throw PermissionException("Read Environment.getExternalStorageDirectory() for more information on the required permissions.")
        }

        val cacheFolderFilter = FileFilter { it.isDirectory && "cache" == it.name }

        for (file in files) {
            if (!file.isDirectory)
                continue

            if (!file.canRead())
                continue

            val cacheFolders = file.listFiles(cacheFolderFilter)

            if (cacheFolders == null) {
                continue
            }

            for (cache in cacheFolders) {
                listVisibleCache.add(
                    Folder(
                        cache.name,
                        countItems(cache),
                        getFolderSize(cache),
                        cache.path
                    )
                )
            }
        }

        return listVisibleCache
    }

    fun getAppData(): List<Folder> {
        val path = Environment.getExternalStorageDirectory().toString() + "/Pictures"
        val listAppData = mutableListOf<Folder>()
        val files = File(path).listFiles() ?: return listAppData

        for (file in files) {
            if (file.isFile || file.name.contains(".")) continue
            if (isDirEmpty(file)) continue

            listAppData.add(
                Folder(
                    file.name,
                    countItems(file),
                    getFolderSize(file),
                    file.path,
                )
            )
        }

        return listAppData
    }

    private fun getFolderSize(file: File): Long {
        if (!file.exists())
            return 0
        if (!file.isDirectory)
            return file.length()
        val dirs: Queue<File> = LinkedList()
        dirs.add(file)
        var result: Long = 0
        while (dirs.isNotEmpty()) {
            val dir = dirs.poll()!!

            if (!dir.exists())
                continue

            val listFiles = dir.listFiles()
            if (listFiles == null || listFiles.isEmpty())
                continue
            for (child in listFiles) {
                // Note: if you want to get physical size and not just logical size, include directories too to the result, and not just normal files
                if (child.isDirectory) {
                    dirs.add(child)
                }
                result += child.length()
            }
        }
        return result
    }

    fun getOldLargeFiles(context: Context, latestObsoleteTimeSinceEpoch: Long, minimumBytes: Long): List<FileInfo> {
        val selection =
            "${MediaStore.Files.FileColumns.SIZE} >= ? AND ${MediaStore.Files.FileColumns.DATE_MODIFIED} < ?"
        val selectionArgs = arrayOf(minimumBytes.toString(), latestObsoleteTimeSinceEpoch.toString())
        return getAllFiles(context, selection, selectionArgs)
    }

    fun getNewLargeFiles(context: Context, newestPhotoTimeSinceEpoch: Long, minimumBytes: Long): List<FileInfo> {
        val selection =
            "${MediaStore.Files.FileColumns.SIZE} >= ? AND ${MediaStore.Files.FileColumns.DATE_MODIFIED} > ?"
        val selectionArgs = arrayOf(minimumBytes.toString(), newestPhotoTimeSinceEpoch.toString())
        return getAllFiles(context, selection, selectionArgs)
    }

    fun getAllFiles(
        context: Context,
        selection: String? = null,
        selectionArgs: Array<String>? = null
    ): List<FileInfo> {
        Log.w(
            "FileManager",
            "This will return incorrect results as media store does not return all files in phone."
        )

        if (!Permissions.isStoragePermissionGranted(context)) {
            throw PermissionException("Storage permissions is required to get the files")
        }

        val contentUri =
            MediaStore.Files.getContentUri("external")

        val projection = arrayOf(MediaStore.Files.FileColumns.DATA, MediaStore.Files.FileColumns.MIME_TYPE)

        val cursor =
            context.contentResolver.query(contentUri, projection, selection, selectionArgs, null)
                ?: return emptyList()

        val files = mutableListOf<FileInfo>()
        while (cursor.moveToNext()) {
            val path: String = cursor.getString(0)
            val mimeType : String? = cursor.getStringOrNull(1)
            val file = File(path)

            files.add(
                FileInfo(
                    mapOf(
                        "idFolder" to file.path.replace(file.name, ""),
                        "name" to file.name,
                        "size" to file.length(),
                        "extensionFile" to file.extension,
                        "path" to file.path,
                        "timeModified" to file.lastModified(),
                        "createdDate" to file.lastModified(),
                        "mimeType" to mimeType
                    )
                )
            )
        }
        cursor.close()
        return files
    }

    fun getDownloads(context: Context): List<com.rocket.device.info.models.File> {
        if (SDK_INT < VERSION_CODES.Q) {
            val directory = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)!!
            val listDownloads = mutableListOf<com.rocket.device.info.models.File>()
            val fileFilter = FileFilter { it.isFile }
            val files = directory.listFiles(fileFilter)

            if (!directory.canRead() || files == null) {
                throw PermissionException("Read Environment.getExternalStorageDirectory() for more information on the required permissions.")
            }

            for (file in files) {
                listDownloads.add(
                    com.rocket.device.info.models.File(
                        file.name,
                        file.path,
                        file.length(),
                        file.extension,
                        file.lastModified()
                    )
                )
            }

            return listDownloads
        } else {
            if (ActivityCompat.checkSelfPermission(
                    context,
                    READ_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                throw PermissionException("READ_EXTERNAL_STORAGE permission is required")
            }

            val uri = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            val projection = arrayOf(
                MediaStore.Downloads.TITLE,
                MediaStore.Downloads.DATA,
                MediaStore.Downloads.SIZE,
                MediaStore.Downloads.DATE_MODIFIED
            )

            val cursor = context.contentResolver.query(uri, projection, null, null, null)
                ?: return emptyList()

            val listDownloads = mutableListOf<com.rocket.device.info.models.File>()
            while (cursor.moveToNext()) {
                listDownloads.add(
                    com.rocket.device.info.models.File(
                        name = cursor.getString(0),
                        path = cursor.getString(1),
                        size = cursor.getString(2).toLong(),
                        extension = cursor.getString(1).substringAfterLast('.'),
                        lastModifiedInMilli = cursor.getString(4).toLong(),
                    )
                )
            }

            cursor.close()
            return listDownloads
        }
    }

    fun getApkFiles(): List<FileInfo> {
        val externalStorageDirectory = Environment.getExternalStorageDirectory()

        if (!externalStorageDirectory.canRead()) {
            //Log.d("FileManager", "Permission")
            throw PermissionException("Read Environment.getExternalStorageDirectory() for more information on the required permissions.")
        }

        val fileFilter = FileFilter {
            (it.isDirectory) || (it.isFile && it.extension == "apk")
        }
        val directories: Queue<File> = LinkedList()
        directories.add(externalStorageDirectory)

        val apks = mutableListOf<FileInfo>()


        while (directories.isNotEmpty()) {
            val directory = directories.poll()!!
            if (directory.isDirectory) {
                directory.listFiles(fileFilter)?.let { directories.addAll(it) }
            } else {
                apks.add(
                    FileInfo(
                        mapOf(
                            "idFolder" to directory.path.replace(directory.name, ""),
                            "name" to directory.name,
                            "size" to directory.length(),
                            "extensionFile" to directory.extension,
                            "path" to directory.path,
                            "timeModified" to directory.lastModified(),
                            "createdDate" to directory.lastModified(),
                        )
                    )
                )
            }
        }
        return apks
    }

    fun getAllMediaFiles(mContext: Context): List<FileInfo> {
        val listAllMediaFiles: MutableList<FileInfo> = mutableListOf()

        return listAllMediaFiles
            .plus(getAllImages(mContext))
            .plus(getAllVideos(mContext))
            .plus(getAllAudios(mContext))
    }

    fun getAllImagesOlderThan(context: Context, epochTime: Long): List<String> {
        val selection = "${MediaStore.Images.Media.DATE_MODIFIED} <= ?"
        val selectionArgs = arrayOf(epochTime.toString())
        return getImagesInDevice(context, selection, selectionArgs).map {
            it.path
        }
    }

    fun getAllImages(context: Context) : List<FileInfo>{
        return getImagesInDevice(context)
    }

    @SuppressLint("Range")
    fun getImagesInDevice(
        context: Context,
        selection: String? = null,
        selectionArgs: Array<String>? = null
    ): List<FileInfo> {
        if (!Permissions.isStoragePermissionGranted(context)) {
            throw PermissionException("Storage permissions is required to get the images")
        }

        val uri: Uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DATA,
            MediaStore.Images.Media.DATE_TAKEN,
        )

        val sortOrder = MediaStore.Images.Media.DATE_TAKEN + " ASC"

        val cursor =
            context.contentResolver.query(uri, projection, selection, selectionArgs, sortOrder)
                ?: return emptyList()

        val images = mutableListOf<FileInfo>()
        while (cursor.moveToNext()) {

            val mediaId : Long = cursor.getLong(0)
            val pathname: String = cursor.getString(1)
            val file = File(pathname)

            if(!file.exists() && file.length() == 0L){
                continue
            }

            val createdDate = cursor.getLong(cursor.getColumnIndex(projection[1]))
            images.add(
                FileInfo(
                    mapOf(
                        "mediaId" to mediaId,
                        "mediaType" to MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE,
                        "idFolder" to file.path.replace(file.name, ""),
                        "name" to file.name,
                        "size" to file.length(),
                        "extensionFile" to file.extension,
                        "path" to file.path,
                        "timeModified" to file.lastModified(),
                        "createdDate" to if(createdDate > 0) createdDate else file.lastModified()
                    )
                )
            )
        }
        cursor.close()
        return images
    }

    fun getAllAudios(context: Context): List<FileInfo> {
        if (!Permissions.isStoragePermissionGranted(context)) {
            throw PermissionException("Storage permissions is required to get the audios")
        }

        val uri: Uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DATA,
        )

        val cursor = context.contentResolver.query(uri, projection, null, null, null)
            ?: return emptyList()

        val audios = mutableListOf<FileInfo>()
        while (cursor.moveToNext()) {
            val mediaId : Long = cursor.getLong(0)
            val audioPath: String = cursor.getString(1)

            val file = File(audioPath)

            audios.add(
                FileInfo(
                    mapOf(
                        "mediaId" to mediaId,
                        "mediaType" to MediaStore.Files.FileColumns.MEDIA_TYPE_AUDIO,
                        "idFolder" to file.path.replace(file.name, ""),
                        "name" to file.name,
                        "size" to file.length(),
                        "extensionFile" to file.extension,
                        "path" to file.path,
                        "timeModified" to file.lastModified(),
                        "createdDate" to file.lastModified()
                    )
                )
            )
        }
        cursor.close()
        return audios
    }

    fun getLargeVideos(context: Context, minimumSize: Long): List<FileInfo> {
        val selection = "${MediaStore.Video.Media.SIZE} >= ?"
        val selectionArgs = arrayOf(minimumSize.toString())
        return getAllVideos(context, selection, selectionArgs)
    }

    fun getAllVideos(
        context: Context,
        selection: String? = null,
        selectionArgs: Array<String>? = null
    ): List<FileInfo> {
        if (!Permissions.isStoragePermissionGranted(context)) {
            throw PermissionException("Storage permissions is required to get the videos")
        }

        val uri: Uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DATA
        )
        val cursor =
            context.contentResolver.query(uri, projection, selection, selectionArgs, null, null)
                ?: return emptyList()

        val videos = mutableListOf<FileInfo>()
        while (cursor.moveToNext()) {
            val mediaId : Long = cursor.getLong(0)
            val videoPath: String = cursor.getString(1)

            val file = File(videoPath)

            videos.add(
                FileInfo(
                    mapOf(
                        "mediaId" to mediaId,
                        "mediaType" to MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO,
                        "idFolder" to file.path.replace(file.name, ""),
                        "name" to file.name,
                        "size" to file.length(),
                        "extensionFile" to file.extension,
                        "path" to file.path,
                        "timeModified" to file.lastModified(),
                        "createdDate" to file.lastModified()
                    )
                )
            )
        }
        cursor.close()

        return videos
    }

    fun runPhotoAnalysisProcess(context: Context){
        //Log.d("PhotoAnalysisProcess", "Start Photo Analysis Service")
        PhotoAnalysisService.startService(context)
    }

    fun getSimilarImages(context: Context): List<List<FileInfo>> {
        var imageGroups = mutableListOf<MutableList<String>>()

        val gson = Gson()
        val listType: Type = object : TypeToken<MutableList<MutableList<String>>>() {}.type
        val jsonData = LocalStorage.readStringData(context, StorageConstant.BundleName.SIMILAR_PHOTO, StorageConstant.Key.SIMILAR_PHOTO)
        if (jsonData.isNotEmpty()) {
            imageGroups = gson.fromJson(jsonData, listType)
            for (i in 0 until imageGroups.size) {
                imageGroups[i] = imageGroups[i].filter {
                    File(it).exists()
                }.toMutableList()
            }

            imageGroups = imageGroups.filter {
                it.size > 1
            }.toMutableList()
        }

        var finalResult = mutableListOf<MutableList<FileInfo>>()
        for (paths in imageGroups) {
            var listFileInfo = mutableListOf<FileInfo>()
            paths.forEach {
                val file = File(it)
                listFileInfo.add(
                    FileInfo(
                        mapOf(
                            "mediaId" to FileInfo.getMediaIdFromPath(context, it),
                            "mediaType" to MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE,
                            "idFolder" to file.path.replace(file.name, ""),
                            "name" to file.name,
                            "size" to file.length(),
                            "extensionFile" to file.extension,
                            "path" to file.path,
                            "timeModified" to file.lastModified(),
                        )
                    )
                )
            }
            finalResult.add(listFileInfo)
        }
        return finalResult
    }

    fun getLowImages(context: Context): List<FileInfo> {
        val dbHelper = MediaDbHelper(context)
        var listPaths = dbHelper.getPathsOfBadPhoto()

        return listPaths.map {
            val file = File(it)
            FileInfo(
                mapOf(
                    "mediaId" to FileInfo.getMediaIdFromPath(context, it),
                    "mediaType" to MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE,
                    "idFolder" to file.path.replace(file.name, ""),
                    "name" to file.name,
                    "size" to file.length(),
                    "extensionFile" to file.extension,
                    "path" to file.path,
                    "timeModified" to file.lastModified(),
                )
            )
        }
    }

    fun isImageValid(path: String): Boolean {
        return ImageProcessing.isImageValid(path)
    }

    fun isOptimizableImage(context: Context, path: String) : Boolean {
        return ImageProcessing.isOptimizableImage(context, path)
    }

    fun optimizeImagePreview(
        context: Context,
        path: String,
        quality: Int,
        resolutionScale: Double,
    ): Map<String, Any> {
        val photoOptimizationResult = ImageProcessing.optimizeImagePreview(context, path, quality, resolutionScale)
        return photoOptimizationResult.toMap()
    }

    fun optimizeImage(
        context: Context,
        path: String,
        quality: Int,
        resolutionScale: Double,
        deleteOriginal: Boolean
    ): OptimizationResult {
        return ImageProcessing.optimizeImage(
            context,
            path,
            quality,
            resolutionScale,
            deleteOriginal
        )
    }

    @Throws(IOException::class)
    private fun isDirEmpty(file: File): Boolean {
        if (SDK_INT >= VERSION_CODES.O) {
            Files.newDirectoryStream(file.toPath())
                .use { dirStream ->
                    return !dirStream.iterator().hasNext()
                }
        } else {
            return file.list()?.isEmpty() ?: true
        }
    }

    @Throws(IOException::class)
    private fun countItems(file: File): Int {
        return if (SDK_INT >= VERSION_CODES.O) {
            Files.newDirectoryStream(file.toPath())
                .count()
        } else {
            file.list()?.size ?: 0
        }
    }

    fun getExternalStorageName() : String {
        return Environment.getExternalStorageDirectory().path
    }
}