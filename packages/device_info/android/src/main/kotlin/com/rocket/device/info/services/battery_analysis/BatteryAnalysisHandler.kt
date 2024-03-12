package com.rocket.device.info.services.battery_analysis

import android.annotation.SuppressLint
import android.content.Context
import com.rocket.device.info.data.sql.helper.BatteryAnalysisDbHelper
import com.rocket.device.info.services.AppInfoUsageManager

object BatteryAnalysisHandler {

    private fun < T : Number > mapIncrement(map : MutableMap<String, T>, key : String, addedValue: T){
        val oldValue = map[key]
        if(oldValue != null){
            map[key] = (oldValue.toDouble() + addedValue.toDouble()) as T
        } else {
            map[key] = addedValue
        }
    }

    private fun getAppsUsageTimeInRange(appsUsageTimeIntervals :  Map<String, List<AppInfoUsageManager.TimeInterval>>, startTimeRecording : Long, endTimeRecording : Long) : MutableMap<String, Long> {

        val appsUsageTime = mutableMapOf<String, Long>()

        appsUsageTimeIntervals.forEach {

            val packageName = it.key
            val timeIntervals = it.value

            val size = timeIntervals.size
            for(i in 0 until size){

                val openedTime = timeIntervals[i].openedTime
                val closedTime = timeIntervals[i].closedTime

                if(openedTime >= endTimeRecording && closedTime <= startTimeRecording){
                    break
                }

                if(openedTime <= startTimeRecording && closedTime >= endTimeRecording){
                    appsUsageTime[packageName] = endTimeRecording - startTimeRecording
                    break
                }

                if(openedTime >= startTimeRecording && closedTime <= endTimeRecording){
                    val addedValue = closedTime - openedTime
                    mapIncrement(appsUsageTime, packageName, addedValue)
                }

                if(openedTime < startTimeRecording && (closedTime in startTimeRecording..endTimeRecording) ){
                    val addedValue = closedTime - startTimeRecording
                    mapIncrement(appsUsageTime, packageName, addedValue)
                }

                if(closedTime > endTimeRecording && (openedTime in startTimeRecording..endTimeRecording) ){
                    val addedValue = endTimeRecording - openedTime
                    mapIncrement(appsUsageTime, packageName, addedValue)
                }
            }
        }

        return appsUsageTime
    }

    private fun sumMapElements(map :  MutableMap<String, Long>) : Long{
        var sum = 0L
        map.forEach {
            sum += it.value
        }
        return sum
    }

    private fun updateAppsUsageBatteryPercentage(appsUsageBatteryPercentage : HashMap<String, Double>, appsUsageTime : MutableMap<String, Long>, batteryPercentageDifferent : Long) {
        var appUsageTimeTotal = sumMapElements(appsUsageTime)

        appsUsageTime.forEach{

            val packageName = it.key
            val appUsageTime = it.value

            if(appUsageTime > 0){

                val ratio = appUsageTime.toDouble() / appUsageTimeTotal

                val appBatteryUsage = batteryPercentageDifferent * ratio

                mapIncrement(appsUsageBatteryPercentage, packageName, appBatteryUsage)
            }
        }
    }

    @SuppressLint("Range")
    fun getBatteryUsagePercentageInRange(context: Context, startTimeInEpoch: Long, endTimeInEpoch: Long) : Map<String, Double>{

        val batteryStatusRows = BatteryAnalysisDbHelper(context).getRowsByTimeAndSort(startTimeInEpoch)

        val appsUsageBatteryPercentage = hashMapOf<String, Double>()

        val appsUsageTimeIntervals = AppInfoUsageManager.getAppsUsageTimeIntervals(context, startTimeInEpoch, endTimeInEpoch)

        var startBatteryPct = 0L;
        var startTimeRecording = 0L
        var endTimeRecording = 0L

        var isInStreakOfCharging = false
        var isInStreakOfNotCharging = false

        for(row in batteryStatusRows){
            val batteryPct = row.batteryLevel.toLong()
            val batteryRecordTime = row.timeStamp
            val isCharging = row.isCharging

            if(isCharging && startTimeRecording > 0 && !isInStreakOfCharging){

                val batteryPercentageDifferent = startBatteryPct - batteryPct
                if(batteryPercentageDifferent <= 0){
                    continue
                }
                endTimeRecording = batteryRecordTime

                val appsUsageTime = getAppsUsageTimeInRange(appsUsageTimeIntervals, startTimeRecording, endTimeRecording)
                updateAppsUsageBatteryPercentage(appsUsageBatteryPercentage, appsUsageTime, batteryPercentageDifferent)

                // update streak
                isInStreakOfCharging = true
                isInStreakOfNotCharging = false
            }

            if(!isCharging){

                if(isInStreakOfNotCharging){

                    val batteryPercentageDifferent = startBatteryPct - batteryPct

                    if(batteryPercentageDifferent > 0){
                        endTimeRecording = batteryRecordTime

                        val appsUsageTime = getAppsUsageTimeInRange(appsUsageTimeIntervals, startTimeRecording, endTimeRecording)
                        updateAppsUsageBatteryPercentage(appsUsageBatteryPercentage, appsUsageTime, batteryPercentageDifferent)
                    }
                }

                startBatteryPct = batteryPct
                startTimeRecording = batteryRecordTime

                // update streak
                isInStreakOfCharging = false
                isInStreakOfNotCharging = true
            }
        }

        return appsUsageBatteryPercentage
    }

    fun getBatteryUsagePercentageInOneDay(context: Context) : Map<String, Double> {
        val currentTime = System.currentTimeMillis()
        return getBatteryUsagePercentageInRange(context, currentTime - 24 * 3600 * 1000, currentTime)
    }

    fun getBatteryUsagePercentageInSevenDays(context: Context) : Map<String, Double> {
        val currentTime = System.currentTimeMillis()
        return getBatteryUsagePercentageInRange(context, currentTime - 7 * 24 * 3600 * 1000, currentTime)
    }
}