package com.rocket.device.info.strange_code.similar_detection;

import android.content.Context;
import android.util.Pair;

import com.rocket.device.info.strange_code.PhotoInfo;
import com.rocket.device.info.data.sql.helper.MediaDbHelper;

import org.opencv.core.Mat;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class SimilarPhotoDetection {
    private static com.rocket.device.info.strange_code.similar_detection.OpenCVOperation OpenCVOperation = new OpenCVOperation();

    private static final Pair<Boolean, Double> compareHistograms(Mat mat, Mat mat2, long j) {
        double similarityScore = SimilarPhotoDetection.OpenCVOperation.compareHistograms(mat, mat2);
        boolean z = true;
        boolean isSimilar = similarityScore > 0.95d || (j < 10000 && similarityScore > 0.85d);
        if (isSimilar) {
            isSimilar = SimilarPhotoDetection.OpenCVOperation.compareHistograms(mat.submat(0, mat.rows() / 2, 0, mat.cols() / 2), mat2.submat(0, mat2.rows() / 2, 0, mat2.cols() / 2)) > 0.8d;
        }
        if (isSimilar) {
            isSimilar = SimilarPhotoDetection.OpenCVOperation.compareHistograms(mat.submat(0, mat.rows() / 2, mat.cols() / 2, mat.cols()), mat2.submat(0, mat2.rows() / 2, mat2.cols() / 2, mat2.cols())) > 0.8d;
        }
        if (isSimilar) {
            isSimilar = SimilarPhotoDetection.OpenCVOperation.compareHistograms(mat.submat(mat.rows() / 2, mat.rows(), 0, mat.cols() / 2), mat2.submat(mat2.rows() / 2, mat2.rows(), 0, mat2.cols() / 2)) > 0.8d;
        }
        if (isSimilar) {
            if (SimilarPhotoDetection.OpenCVOperation.compareHistograms(mat.submat(mat.rows() / 2, mat.rows(), mat.cols() / 2, mat.cols()), mat2.submat(mat2.rows() / 2, mat2.rows(), mat2.cols() / 2, mat2.cols())) <= 0.8d) {
                z = false;
            }
            isSimilar = z;
        }
        return new android.util.Pair<>(isSimilar, similarityScore);
    }

    private static int getIndexWhereStartDetection(List<PhotoInfo> listImages, String pathOfLastImage){
        if(pathOfLastImage == null || pathOfLastImage.isEmpty()){
            return 0;
        }

        int i;
        int size = listImages.size();
        for(i = size - 1; i >= 0; i--){
            if(listImages.get(i).getPath().equals(pathOfLastImage)){
                return i;
            }
        }
        return 0;
    }

    private static List<String> cloneList(List<String> list){
        List<String> clonedList = new ArrayList<String>();
        clonedList.addAll(list);
        return clonedList;
    }

    private static void removeFileNotExist(List<List<String>> list){
        int i,j;
        int size = list.size();
        for(i = 0; i < size; i++){
            List<String> listChild = list.get(i);
            for(j = 0; j < listChild.size(); j++){
                if(!(new File(listChild.get(j))).exists()){
                    listChild.remove(j);
                    j--;
                }
            }
            if(listChild.size() < 2){
                list.remove(i);
                i--;
            }
        }
    }

    public static void similarDetection(Context context, List<List<String>> listToSave){

        MediaDbHelper dbHelper = null;
        List<PhotoInfo> listImages = null;

        try {
            dbHelper = new MediaDbHelper(context);

            listImages = dbHelper.getPhotosFromDatabase(null, null);

        }catch (Exception e){
            return;
        }finally {
            if (dbHelper != null) {
                dbHelper.close();
            }
        }

        if(listImages.size() < 2) return;

        removeFileNotExist(listToSave);

        int startFromIndex = 0;

        List<String> listChild = new ArrayList<>();
        if(listToSave.size() > 0){
            listChild = listToSave.get(listToSave.size() - 1);

            String pathOfLastImage = listChild.get(listChild.size() - 1);
            startFromIndex = getIndexWhereStartDetection(listImages, pathOfLastImage);

            if(startFromIndex == 0){
                listToSave.clear();
                listChild.clear();
            }
        }

        try {
            int size = listImages.size() - 1;
            Mat mat = null;
            int i = -1;
            int i2 = startFromIndex;
            // //Log.d("SimilarDetection", "Start from index: " + i2);
            // //Log.d("SimilarDetection", "Total size: " + listImages.size());
            boolean streak = false;
            while (i2 < size) {
                PhotoInfo sr2 = listImages.get(i2);
                int i3 = i2 + 1;
                PhotoInfo sr22 = listImages.get(i3);

                Mat mat2 = mat;
                long timeDifference = Math.abs(sr2.getDateTaken() - sr22.getDateTaken());
                if (timeDifference > 20000) {

                    if(i2 == startFromIndex && listChild.size() > 0){ // continue to detect from the last similar group
                        listChild = new ArrayList<>();
                        streak = false;
                    }

                    if(streak){
                        listToSave.add(cloneList(listChild));
                        listChild.clear();
                        streak = false;
                    }
                    // //Log.d("SimilarDetection", "false2 :> : " + sr2.getPath() + " --- " + sr22.getPath());
                } else {
                    Mat mat1;
                    if (i != i2 || mat2 == null) {
                        mat1 = SimilarPhotoDetection.OpenCVOperation.readMatFromPath(context, sr2, true);
                    } else {
                        mat1 = mat2;
                    }
                    OpenCVOperation OpenCVOperation = SimilarPhotoDetection.OpenCVOperation;
                    Mat math2 = OpenCVOperation.readMatFromPath(context, sr22, true);
                    if (mat1 == null || math2 == null) {
                        //DebugLog.m70920("DuplicatesHelper.processIMagesFromSource() - matrixes are null");
                    } else {
                        Boolean obj = compareHistograms(mat1, math2, timeDifference).first;

                        if(i2 == startFromIndex && listChild.size() > 0){ // continue to detect from the last similar group
                            if(obj){
                                streak = true;
                            }else {
                                listChild = new ArrayList<>();
                                streak = false;
                            }
                        }

                        if (obj) {
                            if(streak){
                                listChild.add(sr22.getPath());
                                // //Log.d("SimilarDetection", "Group: " + (listToSave.size() + 1) + " , add path: " + sr22.getPath());
                            }else {
                                listChild.add(sr2.getPath());
                                listChild.add(sr22.getPath());
                                // //Log.d("SimilarDetection", "Group: " + (listToSave.size() + 1) + " , add path: " + sr2.getPath());
                                // //Log.d("SimilarDetection", "Group: " + (listToSave.size() + 1) + " , add path: " + sr22.getPath());
                            }

                            if(i3 == size){ // if sr22 is the last photo then save it
                                listToSave.add(cloneList(listChild));

                                // //Log.d("SimilarDetection","Last Item: " + listChild.toString());
                                // //Log.d("SimilarDetection","Last Item: " + listToSave.get(listToSave.size() - 1).toString());

                                listChild.clear();
                            }

                            streak = true;
                        } else {
                            if(streak){
                                listToSave.add(cloneList(listChild));
                                listChild.clear();
                                streak = false;
                            }
                            // //Log.d("SimilarDetection", "false :> : " + sr2.getPath() + " --- " + sr22.getPath());
                        }
                    }
                    mat = math2;
                    i = i3;
                }
                i2 = i3;
            }
        } catch (Throwable th) {
            //DebugLog.m70917("DuplicatesService.processImagesFromSource()", th);
        }

        ////Log.d("SimilarDetection", "Total similar photos: " + count);
    }
}