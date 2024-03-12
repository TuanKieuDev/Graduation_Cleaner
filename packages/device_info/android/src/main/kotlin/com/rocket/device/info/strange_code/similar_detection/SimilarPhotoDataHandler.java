package com.rocket.device.info.strange_code.similar_detection;

import android.content.Context;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.rocket.device.info.core.StorageConstant;
import com.rocket.device.info.data.LocalStorage;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class SimilarPhotoDataHandler {
    private Context context;

    public SimilarPhotoDataHandler(Context context){
        this.context = context;
    }

    public void handleData(){
        List<List<String>> imageGroups = new ArrayList<>();

        Gson gson = new Gson();
        Type listType = new TypeToken<List<List<String>>>() {}.getType();

        String jsonData = LocalStorage.Companion.readStringData(context, StorageConstant.BundleName.INSTANCE.getSIMILAR_PHOTO(), StorageConstant.Key.INSTANCE.getSIMILAR_PHOTO());
        if(!jsonData.isEmpty() && !shouldDetectAllImages()){
            imageGroups = gson.fromJson(jsonData, listType);
        }

        SimilarPhotoDetection.similarDetection(context, imageGroups);

        String dataString = gson.toJson(imageGroups, listType);
        LocalStorage.Companion.writeStringData(context, StorageConstant.BundleName.INSTANCE.getSIMILAR_PHOTO(), StorageConstant.Key.INSTANCE.getSIMILAR_PHOTO(), dataString);
    }

    private boolean shouldDetectAllImages(){
        String bundleName = "time_interval";
        String key = "time";

        Long lastTimeDetection = LocalStorage.Companion.readLongData(context, bundleName, key);
        // //Log.d("SimilarDetection", "Last Time: $lastTimeDetection")
        // //Log.d("SimilarDetection", "CurrentTime: " + System.currentTimeMillis())
        if(lastTimeDetection < 0 || System.currentTimeMillis() - lastTimeDetection > 3 * 24 * 3600 * 1000){
            LocalStorage.Companion.writeLongData(context, bundleName, key, System.currentTimeMillis());
            return true;
        } else {
            return false;
        }
    }
}
