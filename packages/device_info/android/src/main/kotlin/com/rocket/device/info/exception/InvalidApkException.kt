package com.rocket.device.info.exception

class InvalidApkException(message: String? = null, cause: Throwable? = null) : DeviceInfoException(message, cause) {
    constructor(cause: Throwable) : this(null, cause)
}