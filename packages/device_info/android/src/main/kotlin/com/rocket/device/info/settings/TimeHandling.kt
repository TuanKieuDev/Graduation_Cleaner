package com.rocket.device.info.settings

import java.sql.Timestamp
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*

class TimeHandling {
    fun getListOfDaysBetweenTwoDates(month : Int): List<Long> {
        val currentTime = Calendar.getInstance().time

        val lastTime = Calendar.getInstance()
        lastTime.add(Calendar.MONTH, -month)

        val lastTime1 = lastTime.time

        val result: MutableList<Long> = ArrayList()
        val start = Calendar.getInstance()
        start.time = lastTime1
        val end = Calendar.getInstance()
        end.time = currentTime
        end.add(Calendar.DAY_OF_YEAR, 1) //Add 1 day to endDate to make sure endDate is included into the final list
        while (start.before(end)) {
            result.add(start.time.time)
            start.add(Calendar.DAY_OF_YEAR, 1)
        }

        return result
    }

    fun convertTimestampToDate(timeStamp : Long) : String {
        val stamp = Timestamp(timeStamp)
        val date = Date(stamp.time)
        val f: DateFormat = SimpleDateFormat("dd-MM-yyyy")
        val d = f.format(date)

        return d
    }

}