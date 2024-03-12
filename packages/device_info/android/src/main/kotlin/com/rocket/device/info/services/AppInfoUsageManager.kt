package com.rocket.device.info.services

import android.app.usage.UsageEvents
import android.app.usage.UsageEvents.Event
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Context.USAGE_STATS_SERVICE
import com.rocket.device.info.exception.PermissionException
import com.rocket.device.info.models.AppInfoUsage
import com.rocket.device.info.settings.Permissions


object AppInfoUsageManager {

    class TimeInterval(val openedTime: Long, val closedTime: Long) {
    }

    private object EventKey {
        const val ALL_PACKAGES = ""
    }

    private var allEventsMap = hashMapOf<String, MutableList<Event>>()

    fun collectAllEvents(context: Context, packagesNameList : List<String>, startTimeInEpoch: Long, endTimeInEpoch: Long) {

        if(allEventsMap.size > 0){
            allEventsMap.clear()
        }

        val mUsageStatsManager : UsageStatsManager = context.getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager

        val queryEvents: UsageEvents = mUsageStatsManager.queryEvents(startTimeInEpoch, endTimeInEpoch)

        while (queryEvents.hasNextEvent()) {
            var event = Event()
            queryEvents.getNextEvent(event)

            if(!packagesNameList.contains(event.packageName)){
                continue
            }

            if (event.eventType == 1 || event.eventType == 2) {

                var eventsList = allEventsMap[event.packageName]

                if(eventsList != null){
                    eventsList.add(event)
                } else {
                    eventsList = mutableListOf()
                    eventsList.add(event)

                    allEventsMap[event.packageName] = eventsList
                }
            }
        }

        val allEvents = mutableListOf<Event>()
        for(events in allEventsMap.values){
            for(event in events){
                allEvents.add(event)
            }
        }

        allEventsMap[EventKey.ALL_PACKAGES] = allEvents

    }

    private fun compare(obj: Any?, obj2: Any?): Boolean {
        return if (obj == null) obj2 == null else obj == obj2
    }

    private fun getUsageEvents(packageName: String, startTimeInEpoch: Long, endTimeInEpoch: Long) : List<Event>{
        if(allEventsMap.size == 0){
            return listOf()
        }

        if(allEventsMap[packageName] == null){ // unused
            return listOf()
        }

        if(packageName == EventKey.ALL_PACKAGES){ // all apps
            return allEventsMap[packageName]?.filter {
                it.timeStamp in startTimeInEpoch..endTimeInEpoch
            } ?: listOf()
        }

        val firstIndex = allEventsMap[packageName]?.indexOfFirst {
            it.timeStamp >= startTimeInEpoch
        }

        val lastIndex = allEventsMap[packageName]?.indexOfLast {
            it.timeStamp <= endTimeInEpoch
        }

        if(firstIndex == null || firstIndex == -1 || lastIndex == null || lastIndex == -1) {
            return listOf()
        }

        return allEventsMap[packageName]?.subList(firstIndex, lastIndex + 1)?.toList() ?: listOf()
    }

    fun getAppUsageInfo(context: Context, packageName: String, startTimeInEpoch: Long, endTimeInEpoch: Long): String {

        if(!Permissions.isUsageAccessGranted(context)){
            throw PermissionException("Permission denied, need App Usage Permission")
        }

        var timeOpened = 0
        var lastOpened: Long = 0
        var totalTimeInForeground : Long = 0
        var activityPauseTime : Long = 0

        val events = getUsageEvents(packageName, startTimeInEpoch, endTimeInEpoch)

        var appPackageName = ""

        for (event in events) {

            if (!compare(appPackageName, event.packageName) && compare(packageName, EventKey.ALL_PACKAGES)) {
                lastOpened = 0
            }
            appPackageName = event.packageName

            if (event.eventType == Event.ACTIVITY_RESUMED) {
                val timeStamp: Long = event.timeStamp
                if (event.timeStamp - activityPauseTime > 1000) {
                    timeOpened++
                }
                lastOpened = timeStamp
            }
            if (event.eventType == Event.ACTIVITY_PAUSED) {
                if (lastOpened > 0) {
                    totalTimeInForeground += event.timeStamp - lastOpened
                }
                activityPauseTime = event.timeStamp
            }
        }

        return AppInfoUsage(packageName, totalTimeInForeground, timeOpened).toString()
    }

    fun getLastAppUsageTime(context: Context, packageName: String) : Long {

        if(!Permissions.isUsageAccessGranted(context)){
            throw PermissionException("Permission denied, need App Usage Permission")
        }

        val events = getUsageEvents(packageName, 0, System.currentTimeMillis())

        var i = events.size - 1
        while (i >= 0){
            if (events[i].eventType == Event.ACTIVITY_RESUMED) {
                return events[i].timeStamp
            }
            i--
        }

        return 0L
    }

    fun getAppsUsageTimeIntervals(context: Context, startTimeInEpoch: Long, endTimeInEpoch: Long) : Map<String, List<TimeInterval>> {

        if(!Permissions.isUsageAccessGranted(context)){
            throw PermissionException("Permission denied, need App Usage Permission")
        }

        val appsUsageTimeIntervals : HashMap<String, List<TimeInterval>> = hashMapOf()

        val eventsList = getUsageEvents("", startTimeInEpoch, endTimeInEpoch)

        val str = ""
        var str2: String = str
        var i = 0

        var timeIntervals = mutableListOf<TimeInterval>()
        var openedTime = 0L

        var event: UsageEvents.Event? = null
        for (next in eventsList) {
            val i3 = i + 1

            event = next

            if (!(compare(str2, str) || compare(str2, event.packageName))) {

                appsUsageTimeIntervals[str2] = timeIntervals.toList()

                timeIntervals.clear()
            }

            str2 = event.packageName

            if (event.eventType == Event.ACTIVITY_RESUMED) {

                openedTime = event.timeStamp

            }
            if (event.eventType == Event.ACTIVITY_PAUSED) {

                val closedTime = event.timeStamp
                if(closedTime > openedTime && openedTime != 0L){
                    timeIntervals.add(TimeInterval(openedTime, closedTime))
                }

            }
            if (!compare(str2, str) && i == eventsList.size - 1) {

                appsUsageTimeIntervals[str2] = timeIntervals.toList()

            }
            i = i3
        }

        return appsUsageTimeIntervals
    }
}