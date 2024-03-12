package com.rocket.device.info.exception

import android.util.Log
import serializeToMap

inline fun io.flutter.plugin.common.MethodChannel.Result.execute(crossinline body: () -> Any) {
    try {
        val result = body.invoke()
        if (result !is Unit)
            this.success(result)
        else
            this.success(null)
    } catch (deviceInfoException: DeviceInfoException){
        this.error(deviceInfoException.javaClass.name, deviceInfoException.message, deviceInfoException.serializeToMap())
    } catch (e: Throwable){
        Log.e("Unknown", "Unknown exception", e);
        this.error("Unknown", e.message, e.serializeToMap())
    }
}