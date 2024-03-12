package com.rocket.device.info

import android.content.Context
import com.rocket.device.info.exception.DeviceInfoException
import com.rocket.device.info.exception.execute
import com.rocket.device.info.services.FileManager
import com.rocket.device.info.settings.MediaThumbnailUtil
import com.rocket.device.info.util.ResultHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import serializeToMap
import com.rocket.device.info.core.ExecutorService

class FileManagerChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding, name: String) : MethodChannel(flutterPluginBinding.binaryMessenger, name),
    MethodChannel.MethodCallHandler {
    private val applicationContext: Context = flutterPluginBinding.applicationContext

    init {
        setMethodCallHandler(this)
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method){
            "getExternalPath" -> result.execute {
                FileManager.getExternalStorageName()
            }
            "getThumbnails" -> result.execute {
                FileManager.getThumbnails(
                    applicationContext
                ).map { it.toMap() }
            }
            "getEmptyFolders" -> result.execute {
                FileManager.getEmptyFolders(
                    applicationContext
                ).map { it.toMap() }
            }
            "getVisibleCaches" -> result.execute {
                FileManager.getVisibleCaches(
                    applicationContext
                ).map { it.toMap() }
            }
            "getAppData" -> result.execute {
                FileManager.getAppData().map { it.toMap() }
            }
            "getAllFiles" -> result.execute {
                FileManager.getAllFiles(
                    applicationContext,
                    call.argument("selection"),
                    call.argument("selectionArgs")
                )
            }
            "getDownloads" -> result.execute {
                FileManager.getDownloads(
                    applicationContext
                )
            }
            "getAllMediaFiles" -> result.execute {
                FileManager.getAllMediaFiles(
                    applicationContext
                ).map { it.toMap() }
            }
            "getAllImagesOlderThan" -> result.execute {
                FileManager.getAllImagesOlderThan(
                    applicationContext,
                    call.argument("epochTime")!!
                )
            }
            "getImages" -> result.execute {
                FileManager.getImagesInDevice(applicationContext,
                    call.argument("selection"),
                    call.argument("selectionArgs")
                ).map { it.toMap() }
            }
            "getAllVideos" -> result.execute { FileManager.getAllVideos(applicationContext).map { it.toMap() } }
            "runPhotoAnalysisProcess" -> result.execute{
                FileManager.runPhotoAnalysisProcess(applicationContext)
            }
            "getSimilarImages" -> result.execute {
                FileManager.getSimilarImages(
                    applicationContext
                ).map { it.map { it.toMap() } }
            }
            "getAllAudios" -> result.execute {
                FileManager.getAllAudios(
                    applicationContext
                ).map { it.toMap() }
            }
            "getLargeVideos" -> result.execute {
                FileManager.getLargeVideos(
                    applicationContext,
                    call.argument("minimumSize")!!
                ).map { it.toMap() }
            }
            "getLowImages" -> result.execute {
                FileManager.getLowImages(
                    applicationContext
                ).map { it.toMap() }
            }
            "isImageValid" -> result.execute {
                FileManager.isImageValid(
                    call.argument("path")!!
                )
            }
            "isOptimizableImage" -> runOnIOThreadWithResult(result){
                FileManager.isOptimizableImage(
                    applicationContext,
                    call.argument("path")!!,
                )
            }
            "optimizeImagePreview" -> result.execute {
                FileManager.optimizeImagePreview(
                    applicationContext,
                    call.argument("path")!!,
                    call.argument("quality")!!,
                    call.argument("resolutionScale")!!
                )
            }
            "optimizeImage" -> result.execute {
                FileManager.optimizeImage(
                    applicationContext,
                    call.argument("path")!!,
                    call.argument("quality")!!,
                    call.argument("resolutionScale")!!,
                    call.argument("deleteOriginal")!!
                ).toMap()
            }
            "getApkFiles" -> result.execute {
                FileManager.getApkFiles().map { it.toMap() }
            }
            "loadPhotoOrVideoThumbnail" -> runOnIOThreadWithResult(result) {
                MediaThumbnailUtil.loadPhotoOrVideoThumbnail(
                    applicationContext,
                    call.argument("mediaId")!!,
                    call.argument("mediaType")!!,
                    call.argument("thumbnailSize")!!
                )
            }
            "loadAudioThumbnail" -> runOnIOThreadWithResult(result) {
                MediaThumbnailUtil.loadAudioThumbnail(
                    call.argument("path")!!
                )
            }
            else -> result.notImplemented()
        }
    }

    private fun runOnIOThreadWithResult(result: Result, body: () -> Any){
        val resultHandler = ResultHandler(result)

        val scope = CoroutineScope(Dispatchers.IO)
        val job = scope.launch {
            try {
                val value = withContext(ExecutorService.executor.asCoroutineDispatcher()){
                    body.invoke()
                }
                resultHandler.reply(value)
            }catch (deviceInfoException: DeviceInfoException){
                resultHandler.replyError(deviceInfoException.javaClass.name, deviceInfoException.message, deviceInfoException.serializeToMap())
            }
        }

        job.invokeOnCompletion { scope.cancel() }
    }
}