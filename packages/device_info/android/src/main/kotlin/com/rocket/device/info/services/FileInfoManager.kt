package com.rocket.device.info.services

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.RequiresApi
import com.rocket.device.info.models.FileInfo
import com.rocket.device.info.settings.ImageProcessing
import java.io.File
import java.util.*


class FileInfoManager {

    private val TAG = "FileInfoManager"

    @SuppressLint("NewApi")
    fun callScanItent(context: Context?, path: String) {
        MediaScannerConnection.scanFile(context, arrayOf(path), null, null)
    }

    @RequiresApi(Build.VERSION_CODES.P)
    fun getDownloads(): List<FileInfo> {
        val path = Environment.getExternalStorageDirectory().toString() + "/Download/"
        val listDownloads = mutableListOf<FileInfo>()
        val directory = File(path)
        val files = directory.listFiles()

        if (!directory.canRead() || files == null) {
//            Log.d(
//                FileInfoManager::class.java.name,
//                "Directory can't read or list files null (Downloads)"
//            )
            return listDownloads
        }
        for (file in files) {
            if (file.isDirectory) continue
            listDownloads.add(
                FileInfo(
                    mapOf(
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

        return listDownloads
    }

    fun getAPKs(): List<FileInfo> {
        val path = Environment.getExternalStorageDirectory().toString()
        val listFileAPKsInfo = mutableListOf<FileInfo>()
        val directory = File(path)
        val files = directory.listFiles()

        if (!directory.canRead() || files == null) {
            return listFileAPKsInfo
        }
        for (file in files) {
            if (file.isFile) {
                if (!file.name.endsWith(".apk")) continue
                listFileAPKsInfo.add(
                    FileInfo(
                        mapOf(
                            "idFolder" to file.path.replace(file.name, ""),
                            "name" to file.name,
                            "size" to file.length(),
                            "extensionFile" to file.extension,
                            "path" to file.path,
                            "timeModified" to file.lastModified(),
                        )
                    )
                )
            } else if (!file.isDirectory) continue
            val dirDownload = file.listFiles()
            for (dir in dirDownload!!) {
                if (!(dir.isFile && dir.name.endsWith(".apk"))) continue
                listFileAPKsInfo.add(
                    FileInfo(
                        mapOf(
                            "idFolder" to dir.path,
                            "name" to dir.name,
                            "size" to dir.length(),
                            "extensionFile" to dir.extension,
                            "path" to dir.path,
                            "timeModified" to dir.lastModified(),
                        )
                    )
                )
            }
        }


        return listFileAPKsInfo
    }

    @SuppressLint("Range")
    fun getAllImages(mContext: Context): List<FileInfo> {
        val listImages: MutableList<FileInfo> = ArrayList()
        val uri: Uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Images.Media.DATA
        )
        val cursor = mContext.contentResolver.query(uri, projection, null, null, null)
            ?: return listImages
        var file: File
        while (cursor.moveToNext()) {
            val imageName: String = cursor.getString(cursor.getColumnIndex(projection[0]))
            file = File(imageName)
            listImages.add(
                FileInfo(
                    mapOf(
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
        cursor.close()
        return listImages
    }

    @SuppressLint("Range")
    fun getAllAudios(mContext: Context): List<FileInfo> {
        val listAudios: MutableList<FileInfo> = ArrayList()
        val uri: Uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            arrayOf(
                MediaStore.Audio.Media.DATA
            )
        } else {
            TODO("VERSION.SDK_INT < Q")
        }
        val cursor = mContext.contentResolver.query(uri, projection, null, null, null)
        if (cursor != null) {
            var file: File
            while (cursor.moveToNext()) {
                val audioPath: String = cursor.getString(cursor.getColumnIndex(projection[0]))
                file = File(audioPath)
                listAudios.add(
                    FileInfo(
                        mapOf(
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
            cursor.close()
        }
        return listAudios
    }

    @SuppressLint("Range")
    fun getAllVideos(mContext: Context): List<FileInfo> {
        val listVideos = mutableListOf<FileInfo>()
        val uri: Uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Video.Media.DATA
        )
        val cursor = mContext.contentResolver.query(uri, projection, null, null, null)
        if (cursor != null) {
            var file: File
            while (cursor.moveToNext()) {
                val videoPath: String = cursor.getString(cursor.getColumnIndex(projection[0]))
                file = File(videoPath)
                if (file.path.contains("CCleaner") || file.path.contains("RocketCleaner")) continue
                listVideos.add(
                    FileInfo(
                        mapOf(
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
            cursor.close()
        }

        return listVideos
    }

    fun getSimilarImages(context: Context, similarityLevel: Double, minSize: Int) : MutableList<MutableList<Int>> {

        var imageGroups = mutableListOf<MutableList<Int>>()
        val allImages = getAllImages(context)

        var i = 0
        while (i < allImages.size - 1){
            //Log.d("Test", "Start compare 1: " + i + "- " + allImages[i].path + " - " + allImages[i + 1].path);
            val similarity = ImageProcessing.similarImage(allImages[i].path, allImages[i + 1].path, minSize)
            if(similarity >= similarityLevel){
                var list = mutableListOf<Int>()
                list.add(i)
                list.add(i+1)
                i = i + 1
                while (i < allImages.size - 1){
                    //Log.d("Test", "Start compare 2: " + i + "- " + allImages[i].path + " - " + allImages[i + 1].path);
                    val similarity = ImageProcessing.similarImage(allImages[i].path, allImages[i + 1].path, minSize)
                    if(similarity >= similarityLevel){
                        list.add(i + 1)
                    }else{
                        break
                    }
                    i++
                }
                imageGroups.add(list);
            }
            i++
        }

        //Log.d("Test", "Returned");

        return imageGroups
    }

    @SuppressLint("Range")
    fun getLargeVideos(mContext: Context): List<FileInfo> {
        val listVideos: MutableList<FileInfo> = ArrayList()
        val uri: Uri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Video.Media.DATA
        )
        val cursor = mContext.contentResolver.query(uri, projection, null, null, null)
        if (cursor != null) {
            var file: File
            while (cursor.moveToNext()) {
                val videoPath: String = cursor.getString(cursor.getColumnIndex(projection[0]))
                file = File(videoPath)
                if (file.length() < 20000000) continue
                listVideos.add(
                    FileInfo(
                        mapOf(
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
            cursor.close()
        }
        return listVideos
    }


    @SuppressLint("Range", "NewApi")
    fun getAllFiles(mContext: Context): List<FileInfo> {
        val listAllFiles: MutableList<FileInfo> = ArrayList()
        val contentUri =
            MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL)
        val projection = arrayOf(
            MediaStore.Files.FileColumns.DATA,
        )

        val cursor = mContext.contentResolver.query(contentUri, projection, null, null, null)
        if (cursor != null) {
            var file: File
            while (cursor.moveToNext()) {
                val path: String = cursor.getString(cursor.getColumnIndex(projection[0]))
                file = File(path)
                if (!file.isFile) continue
                listAllFiles.add(
                    FileInfo(
                        mapOf(
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
            cursor.close()
        }


        return listAllFiles
    }

    fun getAllMediaFiles(mContext: Context): List<FileInfo> {
        val listAllMediaFiles: MutableList<FileInfo> = ArrayList()

        return listAllMediaFiles
            .plus(getAllVideos(mContext))
            .plus(getAllAudios(mContext))
            .plus(getAllImages(mContext))
    }

    fun getOldImagesBetween1Month(mContext: Context): List<FileInfo> {
        var listOldImagesBetween1Month: MutableList<FileInfo> = ArrayList()
        val currentTime = System.currentTimeMillis()

        for (image in getAllImages(mContext)) {
            if (image.timeModified > (currentTime - 2629743830)) continue
            listOldImagesBetween1Month.add(image)
        }

        return listOldImagesBetween1Month
    }

    fun getOldLargeFilesBetween6Month(mContext: Context): List<FileInfo> {

        val listOldFilesBetween6Month = mutableListOf<FileInfo>()
        val currentTime = System.currentTimeMillis()

        val getAllFilesTemp : List<FileInfo> = getAllFiles(mContext)

        for (file in  getAllFilesTemp) {
            if (file.timeModified > (currentTime - 15778463000)) continue
            listOldFilesBetween6Month.add(file)
        }

        return listOldFilesBetween6Month
    }

    fun getLargeFiles(mContext: Context): List<FileInfo> {
        val listLargeFile = mutableListOf<FileInfo>()

        for (i in 0 until getAllImages(mContext).size) {
            if (getAllImages(mContext)[i].size <= 20000000) continue
            listLargeFile.add(getAllFiles(mContext)[i])
        }
        return listLargeFile
    }

    fun getSensitiveImages(context: Context): List<FileInfo> {
        val path = Environment.getExternalStorageDirectory().toString() + "/Pictures"
        val listFileAPKsInfo = mutableListOf<FileInfo>()
        val directory = File(path)
        val files = directory.listFiles()

        if (!directory.canRead() || files == null) {
            return listFileAPKsInfo
        }
        for (file in files) {
            if (!file.isDirectory) continue
            val dirSensitive = file.listFiles()
            for (dir in dirSensitive!!) {
                if (!(dir.isFile)) continue
                if (dir.path.contains(".thumbnails")) continue
                listFileAPKsInfo.add(
                    FileInfo(
                        mapOf(
                            "idFolder" to dir.path.replace(dir.name, ""),
                            "name" to dir.name,
                            "size" to dir.length(),
                            "extensionFile" to dir.extension,
                            "path" to dir.path,
                            "timeModified" to dir.lastModified(),
                        )
                    )
                )
                callScanItent(context, dir.path)
            }
        }

        return listFileAPKsInfo
    }

    fun getLowImage(context: Context): List<FileInfo> {
        val listLowImage = mutableListOf<FileInfo>()

        for (fileInStorage in getAllImages(context)) {
            val fileSize = fileInStorage.size / 1024
            if (fileSize >= 100) continue
            listLowImage.add(fileInStorage)
        }

        return listLowImage
    }

    fun optimizeInterface(path: String, quality: Int, isChange: Boolean): String {
        ImageProcessing.compressImageInterface(path, quality, isChange)
        return ""
    }

    fun isImageValid(path: String) : Boolean {
        return ImageProcessing.isImageValid(path)
    }

//    fun optimizeImagePreview(
//        context: Context,
//        path: String,
//        quality: Int,
//        resolutionScale: Double,
//    ): Map<String, Any> {
//        val list = ImageProcessing.compressImage(context, path, quality, resolutionScale, false, false, "")
//        return PhotoOptimizationResult(
//            list[0] as Long,
//            list[1] as Long,
//            list[2] as ByteArray
//        ).toMap()
//    }
//
//    fun optimizeImage(
//        context: Context,
//        path: String,
//        quality: Int,
//        resolutionScale: Double,
//        deleteOriginal: Boolean,
//        packageName: String
//    ) : OptimizationResult {
//        val list = ImageProcessing.compressImage(context, path, quality, resolutionScale,true, deleteOriginal, packageName)
//        return OptimizationResult(
//            list[0] as FileInfo?,
//            list[1] as FileInfo,
//            list[2] as Long,
//        )
//    }

    fun deleteListFiles(listPaths: List<String>, context: Context) {
        for (path in listPaths) {
            deleteFile(path, context)
        }
    }

    fun deleteFile(path: String, context: Context): String {
        val file = File(path)
        val notificationTest: String
        val result = file.deleteRecursively()


        if (result) {
            notificationTest = " Deletion succeeded."
            println("$path Deletion succeeded.")
        } else {
            notificationTest = "Deletion failed."
            println("$path Deletion failed.")
        }

        return notificationTest
    }

    fun refreshMedia(path: String, context: Context): String {
        return try {
            if (path == null)
                throw NullPointerException()
            val file = File(path)
            if (android.os.Build.VERSION.SDK_INT < 29) {
                context.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file)))
            } else {
                MediaScannerConnection.scanFile(context, arrayOf(file.toString()),
                    arrayOf(file.name), null)
            }
            //Log.d("Media Scanner", "Success show image $path in Gallery")
            "Success show image $path in Gallery"
        } catch (e: Exception) {
            Log.e("Media Scanner", e.toString())
            e.toString()
        }

    }


    companion object
}