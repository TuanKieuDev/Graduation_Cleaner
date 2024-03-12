package com.rocket.device.info.exception

class AndroidRestrictionException(message: String? = null, cause: Throwable? = null) : DeviceInfoException(message, cause) {
    constructor(cause: Throwable) : this(null, cause)
}