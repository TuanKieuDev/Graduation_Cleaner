package com.rocket.device.info.core

import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

object ExecutorService {
    val executor: ExecutorService = Executors.newFixedThreadPool(5)
}