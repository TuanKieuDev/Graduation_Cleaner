package com.rocket.device.info.settings

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Size
import com.rocket.device.info.core.utils.MediaStoreUtils
import com.rocket.device.info.exception.AndroidRestrictionException

object MediaThumbnailUtil {

    fun loadPhotoOrVideoThumbnail(
        context: Context,
        mediaId: Long,
        mediaType: Int,
        thumbnailSize: Int
    ) : ByteArray {
        val uri = getUri(mediaId, mediaType)

        try {
            var thumbnail = if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q){
                val size = Size(thumbnailSize, thumbnailSize)
                context.contentResolver.loadThumbnail(uri, size, null)
            }else{
                getThumbnailForPreAndroidQ(context, mediaId, mediaType)
            }

            if(thumbnail == null){
                throw AndroidRestrictionException("Thumbnail request error: File type must be photo or video!")
            }

            return thumbnail.toByteArray()
        }catch (e : java.lang.Exception){
            throw AndroidRestrictionException("Thumbnail request error: $e")
        }
    }

    private fun getUri(mediaId: Long, mediaType: Int): Uri = MediaStoreUtils.getUri(
        mediaId,
        MediaStoreUtils.convertTypeToMediaType(mediaType)
    )

    private fun getThumbnailForPreAndroidQ(context: Context, mediaId: Long, mediaType: Int) : Bitmap?{
        if(mediaType == MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE){
            return MediaStore.Images.Thumbnails.getThumbnail(
                context.contentResolver,
                mediaId,
                MediaStore.Images.Thumbnails.MINI_KIND,
                null
            )
        }else if(mediaType == MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO){
            return MediaStore.Video.Thumbnails.getThumbnail(
                context.contentResolver,
                mediaId,
                MediaStore.Video.Thumbnails.MINI_KIND,
                null
            )
        }

        return null
    }

    fun loadAudioThumbnail(path: String) : ByteArray {
        return getAudioThumbnail(path)?.toByteArray() ?: ByteArray(0)
    }

    private fun getAudioThumbnail(path: String) : Bitmap?{
        val retriever = MediaMetadataRetriever()
        retriever.setDataSource(path)
        val art: ByteArray? = retriever.embeddedPicture
        if (art != null) {
            return BitmapFactory.decodeByteArray(art, 0, art.size)
        }
        return null
    }
}