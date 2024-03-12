package com.rocket.device.info.settings

import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.util.Size
import com.rocket.device.info.strange_code.PhotoInfo
import com.rocket.device.info.strange_code.similar_detection.OpenCVOperation
import com.rocket.device.info.device.DeviceParams
import com.rocket.device.info.exception.PermissionException
import com.rocket.device.info.models.FileInfo
import com.rocket.device.info.models.OptimizationResult
import com.rocket.device.info.models.PhotoOptimizationResult
import org.opencv.android.Utils
import org.opencv.core.*
import org.opencv.imgproc.Imgproc
import java.io.*
import java.util.*
import kotlin.math.*


object ImageProcessing {

    private val OpenCVOperation = OpenCVOperation()


    private const val ORIGINAL_FOLDER_NAME = "Rocket Cleaner Originals";
    private const val ORIGINAL_FOLDER_PATH = "Pictures/$ORIGINAL_FOLDER_NAME/"
    private val scaleAnchorPoints = doubleArrayOf(0.75, 1.0, 1.25, 1.5)

    fun optimizeImagePreview(context: Context, path: String, quality: Int, resolutionScale: Double) : PhotoOptimizationResult {

        checkInvalidCasesAndThrowError(context, path)

        val bmp = resizeImageAndKeepRotation(context, path, resolutionScale)

        val stream = ByteArrayOutputStream()
        compressAndSaveBitmapToStream(bmp, quality, stream)

        val beforeSize = File(path).length()
        val afterSize = min(stream.size().toLong(), beforeSize)
        val bitmapToShow = stream.toByteArray()

        return PhotoOptimizationResult(
            beforeSize,
            afterSize,
            bitmapToShow
        )
    }

    fun optimizeImage(context: Context, path: String, quality: Int, resolutionScale: Double, deleteOriginal: Boolean): OptimizationResult {

        checkInvalidCasesAndThrowError(context, path)

        val bmp = resizeImageAndKeepRotation(context, path, resolutionScale)

        val stream = ByteArrayOutputStream()
        compressAndSaveBitmapToStream(bmp, quality, stream)

        val imageFile = File(path)

        var originalPhoto : FileInfo? = null
        if(!deleteOriginal){
            originalPhoto = saveOriginalPhoto(context, imageFile)
        }

        val beforeSize = imageFile.length()
        val afterSize = stream.size()
        if(afterSize <= beforeSize){
            // override compressed photo
            val os = FileOutputStream(imageFile)
            compressAndSaveBitmapToStream(bmp, quality, os)
            os.close()
        }
        stream.close()

        val optimizedPhoto = renameFile(imageFile, imageFile.nameWithoutExtension + "_optimized.jpg")

        val savedSpaceInBytes = max(beforeSize - afterSize, 0)

        return OptimizationResult(
            originalPhoto,
            optimizedPhoto,
            savedSpaceInBytes
        )
    }

    private fun checkInvalidCasesAndThrowError(context: Context, path: String){
        if(!Permissions.isStoragePermissionGranted(context)){
            throw PermissionException("Permission isn't reached, please call a method to request STORAGE permission", Throwable("PermissionError"))
        }

        if(!File(path).exists()){
            throw FileNotFoundException("$path not found!")
        }
    }
    private fun resizeImageAndKeepRotation(context: Context, imagePath: String, resolutionScale: Double) : Bitmap{
        var bmp = getBitmapWithUnchangedOrientation(imagePath)
        bmp = resizeBitmap(context, bmp, resolutionScale)
        return bmp
    }
    private fun getBitmapWithUnchangedOrientation(path : String) : Bitmap {

        val exif = ExifInterface(path)
        val orientation: Int = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 1)
        val matrix = Matrix()
        if (orientation == ExifInterface.ORIENTATION_ROTATE_90) {
            matrix.postRotate(90F)
        } else if (orientation == ExifInterface.ORIENTATION_ROTATE_180) {
            matrix.postRotate(180F)
        } else if (orientation == ExifInterface.ORIENTATION_ROTATE_270) {
            matrix.postRotate(270F)
        }

        val bmp = BitmapFactory.decodeFile(path)

        return Bitmap.createBitmap(bmp, 0, 0, bmp.width, bmp.height, matrix, true)
    }

    private fun resizeBitmap(context: Context, bmp: Bitmap, resolutionScale: Double) : Bitmap{
        val widthOriginal = bmp.width
        val heightOriginal = bmp.height

        for(number in scaleAnchorPoints){
            val newSize = getNewSize(context, widthOriginal, heightOriginal, number)
            if(number < resolutionScale){
                if(newSize.width == widthOriginal && newSize.height == heightOriginal){
                    break
                }
            }else if(number == resolutionScale){
                if(newSize.width != widthOriginal || newSize.height != heightOriginal){
                    return Bitmap.createScaledBitmap(bmp, newSize.width, newSize.height, true)
                }
            }else{
                break
            }
        }
        return bmp
    }

    private fun getNewSize(context: Context, widthPhoto: Int, heightPhoto: Int, screenScale: Double) : Size {

        val screenSize = DeviceParams.getScreenSize(context);

        val expectationWidth = ( screenSize.width * screenScale ) * 1.1
        var expectationHeight = ( screenSize.height * screenScale ) * 1.1

        var widthAspectRatio = 1.0
        var heightAspectRatio = 1.0

        if(heightPhoto >= widthPhoto){ // portrait photo

            if(widthPhoto <= expectationWidth || heightPhoto <= expectationHeight){
                return Size(widthPhoto, heightPhoto)
            }

            widthAspectRatio = expectationWidth / widthPhoto
            heightAspectRatio = expectationHeight / heightPhoto

        } else { // landscape photo

            if(widthPhoto <= expectationHeight || heightPhoto <= expectationWidth){
                return Size(widthPhoto, heightPhoto)
            }

            widthAspectRatio = expectationHeight / widthPhoto
            heightAspectRatio = expectationWidth / heightPhoto
        }

        val aspectRatio = max(widthAspectRatio, heightAspectRatio)

        val newWidth = ( widthPhoto * aspectRatio ).toInt()
        val newHeight = ( heightPhoto * aspectRatio ).toInt()

        return Size(newWidth, newHeight)
    }

    private fun compressAndSaveBitmapToStream(bitmap: Bitmap, quality: Int, outputStream: OutputStream){
        bitmap.compress(
            Bitmap.CompressFormat.JPEG,
            quality,
            outputStream
        )
    }
    private fun getUriToSaveImage(contentResolver: ContentResolver, directory : String, fileName: String) : Uri? {
        val images: Uri
        images = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        } else {
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        }

        val contentValues = ContentValues()
        contentValues.put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
        if(directory.isNotEmpty()){
            contentValues.put(MediaStore.Images.Media.RELATIVE_PATH, directory)
        }
        contentValues.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
        return contentResolver.insert(images, contentValues)
    }

    private fun saveOriginalPhoto(context: Context, photoToSave: File) : FileInfo? {

        var fileName = photoToSave.nameWithoutExtension
        var expectationPath = Environment.getExternalStorageDirectory().absolutePath + "/" + ORIGINAL_FOLDER_PATH + fileName + ".jpg"

        if(expectationPath == photoToSave.path){
            fileName += "_o"
            expectationPath = Environment.getExternalStorageDirectory().absolutePath + "/" + ORIGINAL_FOLDER_PATH + fileName + ".jpg"
        }

        val contentResolver = context.contentResolver

        val uri = getUriToSaveImage(contentResolver, ORIGINAL_FOLDER_PATH, fileName)
        val outputStream = uri?.let { it1 -> contentResolver.openOutputStream(it1) }
        val inputStream: InputStream = FileInputStream(photoToSave)
        try {
            val buf = ByteArray(1024)
            var len: Int
            while (inputStream.read(buf).also { len = it } > 0) {
                outputStream?.write(buf, 0, len)
            }
        } catch (e: Exception){
            Log.e("ImageProcessing", "Save original image failed!", e)
        } finally {
            outputStream?.close();
            inputStream.close();
        }


//        inputStream.close()
//        outputStream?.close()

        val file = File(expectationPath)
        if(!file.exists()) return null

        return FileInfo(
            mapOf(
                "idFolder" to file.path.replace(file.name, ""),
                "name" to file.name,
                "size" to file.length(),
                "extensionFile" to file.extension,
                "path" to file.path,
                "timeModified" to file.lastModified(),
            )
        )
    }

    private fun renameFile(fileToRename: File, newName: String) : FileInfo {
        val fileDest = File(fileToRename.parent + File.separator + newName)
        fileToRename.renameTo(fileDest)

        return FileInfo(
            mapOf(
                "idFolder" to fileDest.path.replace(fileDest.name, ""),
                "name" to fileDest.name,
                "size" to fileDest.length(),
                "extensionFile" to fileDest.extension,
                "path" to fileDest.path,
                "timeModified" to fileDest.lastModified(),
            )
        )
    }

    fun compressImageInterface(path: String, quality: Int, isChange: Boolean) {

    }
    fun similarImage(pathOne: String, pathTwo: String, minSize: Int): Double {

        if (abs(File(pathOne).lastModified() - File(pathTwo).lastModified()) > 2 * 60 * 1000) { // 2 minutes
            return 0.0
        }

        val options1 = BitmapFactory.Options()
        val options2 = BitmapFactory.Options()
        options1.inJustDecodeBounds = true
        options2.inJustDecodeBounds = true

        BitmapFactory.decodeFile(pathOne, options1)
        BitmapFactory.decodeFile(pathTwo, options2)

        // resize first photo
        var ratio = 1.0
        if (options1.outWidth > minSize && options1.outHeight > minSize) {
            ratio = min(options1.outWidth, options1.outHeight) / minSize.toDouble()
        }
        options1.inJustDecodeBounds = false;
        options1.inSampleSize = ratio.roundToInt()
        val bitmap1 = BitmapFactory.decodeFile(pathOne, options1)

        // resize second photo
        ratio = 1.0
        if (options2.outWidth > minSize && options2.outHeight > minSize) {
            ratio = min(options2.outWidth, options2.outHeight) / minSize.toDouble()
        }
        options2.inJustDecodeBounds = false;
        options2.inSampleSize = ratio.roundToInt()
        val bitmap2 = BitmapFactory.decodeFile(pathOne, options2)

        val srcBase = Mat()
        val srcTest1 = Mat()
        Utils.bitmapToMat(bitmap1, srcBase)
        Utils.bitmapToMat(bitmap2, srcTest1)

        val hsvBase = Mat()
        val hsvTest1 = Mat()

        Imgproc.cvtColor(srcBase, hsvBase, Imgproc.COLOR_BGR2HSV)
        Imgproc.cvtColor(srcTest1, hsvTest1, Imgproc.COLOR_BGR2HSV)
        val hsvHalfDown = hsvBase.submat(
            Range(hsvBase.rows() / 2, hsvBase.rows() - 1),
            Range(0, hsvBase.cols() - 1)
        )
        val hBins = 5
        val sBins = 10
        val histSize = intArrayOf(hBins, sBins)
        // hue varies from 0 to 179, saturation from 0 to 255
        val ranges = floatArrayOf(0f, 180f, 0f, 256f)
        // Use the 0-th and 1-st channels
        val channels = intArrayOf(0, 1)
        val histBase = Mat()
        val histHalfDown = Mat()
        val histTest1 = Mat()
        val hsvBaseList: List<Mat> = Arrays.asList(hsvBase)
        Imgproc.calcHist(
            hsvBaseList,
            MatOfInt(*channels),
            Mat(),
            histBase,
            MatOfInt(*histSize),
            MatOfFloat(*ranges),
            false
        )
        Core.normalize(histBase, histBase, 0.0, 1.0, Core.NORM_MINMAX)
        val hsvHalfDownList: List<Mat> = Arrays.asList(hsvHalfDown)
        Imgproc.calcHist(
            hsvHalfDownList,
            MatOfInt(*channels),
            Mat(),
            histHalfDown,
            MatOfInt(*histSize),
            MatOfFloat(*ranges),
            false
        )
        Core.normalize(histHalfDown, histHalfDown, 0.0, 1.0, Core.NORM_MINMAX)
        val hsvTest1List: List<Mat> = Arrays.asList(hsvTest1)
        Imgproc.calcHist(
            hsvTest1List,
            MatOfInt(*channels),
            Mat(),
            histTest1,
            MatOfInt(*histSize),
            MatOfFloat(*ranges),
            false
        )
        val baseTest1 = Imgproc.compareHist(histBase, histTest1, 0)

        return baseTest1
    }

    fun isOptimizableImage(context: Context, path: String) : Boolean{
        try {
            if(path.contains(ORIGINAL_FOLDER_NAME)){ // image has optimized before
                return false
            }

            val options = BitmapFactory.Options()
            options.inJustDecodeBounds = true

            BitmapFactory.decodeFile(path, options)

            val widthOriginal = options.outWidth
            val heightOriginal = options.outHeight

            var newSize = getNewSize(context, widthOriginal, heightOriginal, scaleAnchorPoints[1]) // for 1.0
            if(newSize.width == widthOriginal || newSize.height == widthOriginal){
                return false
            }

            return true
        } catch (e : Exception){
            return false
        }
    }

    fun isBlurryImage(context: Context, imagePath: String): Boolean {
        var image: Mat? = null
        var matGray = Mat()
        val destination = Mat()
        val median = MatOfDouble()
        val std = MatOfDouble()
        try {
            val threshold = 50.0

            image = OpenCVOperation.readMatFromPath(context, PhotoInfo(
                imagePath,
                0,
                0, 0,
                0.0,
                0.0, 0.0, 0, 0.0, false, false, false
            ), true)
//                Imgcodecs.imread(imagePath)

            if (image == null || image.empty()){
                return false
            }

            if (image.channels() >= 3){
                Imgproc.cvtColor(image, matGray, Imgproc.COLOR_BGR2GRAY)
            }

            if (matGray.empty()){
                matGray = image
                if (matGray.empty()){
                    return false
                }
                return false
            }

            Imgproc.Laplacian(matGray, destination, 3)


            Core.meanStdDev(destination, median, std)

            val fm = std[0, 0][0].pow(2.0)

            return fm < threshold
        } catch (e: UnsatisfiedLinkError) {
            Log.e("ImageProcessing", "Unsatisfied link", e);
            return false
        }
        catch (e : java.lang.Exception){
            return false
        } catch (e: Throwable){
            return false
        } finally {
            image?.release()
            matGray.release()
            destination.release()
            median.release()
            std.release()
        }
    }

    fun isImageValid(path: String) : Boolean {
        val imageFile = File(path)
        if(!imageFile.exists()){
            return false
        }
        var bmp = BitmapFactory.decodeFile(imageFile.absolutePath);
        if(bmp == null){
            return false
        }
        if(bmp.width <= 0 || bmp.height <= 0){
            return false
        }
        return true
    }
}



