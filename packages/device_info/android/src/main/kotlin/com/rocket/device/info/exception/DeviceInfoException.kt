package com.rocket.device.info.exception

open class DeviceInfoException(message: String? = null, cause: Throwable? = null) : Exception(message, cause) {
    constructor(cause: Throwable) : this(null, cause)
}