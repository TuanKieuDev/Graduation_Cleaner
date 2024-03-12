package com.rocket.device.info.data

import android.content.Context

class LocalStorage {
    companion object {
        fun readStringData(context: Context, bundleName: String, key: String) : String {
            val sharedPref = context.getSharedPreferences(bundleName, Context.MODE_PRIVATE)
            val data = sharedPref.getString(key, "")
            if(data != null && data.isNotEmpty()){
                return data
            }
            return ""
        }

        fun writeStringData(context: Context, bundleName: String, key: String, data: String){
            val sharedPref = context.getSharedPreferences(bundleName, Context.MODE_PRIVATE)
            val editor = sharedPref.edit()
            editor.putString(key, data)
            editor.apply()
        }

        fun readLongData(context: Context, bundleName: String, key: String) : Long {
            val sharedPref = context.getSharedPreferences(bundleName, Context.MODE_PRIVATE)
            val data = sharedPref.getLong(key, -1)
            return data
        }

        fun writeLongData(context: Context, bundleName: String, key: String, data: Long){
            val sharedPref = context.getSharedPreferences(bundleName, Context.MODE_PRIVATE)
            val editor = sharedPref.edit()
            editor.putLong(key, data)
            editor.apply()
        }

        fun readFloatData(context: Context, bundleName: String, key: String) : Float {
            val sharedPref = context.getSharedPreferences(bundleName, Context.MODE_PRIVATE)
            val data = sharedPref.getFloat(key, -1.0f)
            return data
        }

        fun writeFloatData(context: Context, bundleName: String, key: String, data: Float){
            val sharedPref = context.getSharedPreferences(bundleName, Context.MODE_PRIVATE)
            val editor = sharedPref.edit()
            editor.putFloat(key, data)
            editor.apply()
        }

        fun readBooleanData(context: Context, bundleName: String, key: String) : Boolean {
            val sharedPref = context.getSharedPreferences(bundleName, Context.MODE_PRIVATE)
            val data = sharedPref.getBoolean(key, false)
            return data
        }

        fun writeBooleanData(context: Context, bundleName: String, key: String, data: Boolean){
            val sharedPref = context.getSharedPreferences(bundleName, Context.MODE_PRIVATE)
            val editor = sharedPref.edit()
            editor.putBoolean(key, data)
            editor.apply()
        }
    }
}