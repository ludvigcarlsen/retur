package com.example.retur

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

/**
 * Schedules widget refreshes. The freshness strategy:
 *  - render-time filtering drops already-departed trips,
 *  - an expiry alarm re-renders right after the soonest shown departure leaves,
 *  - unlock re-renders immediately (see UserPresentReceiver),
 *  - WorkManager's 15-minute job is only a backstop for realtime changes (delays).
 */
object WidgetScheduler {
    private const val PERIODIC_WORK = "retur_widget_periodic"

    private val networkConstraint = Constraints.Builder()
        .setRequiredNetworkType(NetworkType.CONNECTED)
        .build()

    /** Periodic backstop refetch (15-minute minimum imposed by the platform). */
    fun schedulePeriodic(context: Context) {
        val request = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(15, TimeUnit.MINUTES)
            .setConstraints(networkConstraint)
            .build()
        WorkManager.getInstance(context)
            .enqueueUniquePeriodicWork(PERIODIC_WORK, ExistingPeriodicWorkPolicy.KEEP, request)
    }

    /**
     * Re-render right after the soonest shown departure leaves, so the expired trip
     * drops off. Uses an exact alarm when the user has granted "Alarms & reminders"
     * (reliable, fires through Doze); otherwise an inexact alarm, with periodic/unlock
     * refresh as the safety net.
     */
    fun scheduleExpiryRefresh(context: Context, departureEpochMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, DepartureAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        // +1s so the trip has clearly departed by the time we re-render.
        val triggerAt = departureEpochMillis + 1_000L

        val canExact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            alarmManager.canScheduleExactAlarms()
        if (canExact) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        } else {
            alarmManager.set(AlarmManager.RTC, triggerAt, pendingIntent)
        }
    }

    /** Whether we can fire exact alarms (drives whether the live "in X min" is trustworthy). */
    fun canScheduleExact(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return alarmManager.canScheduleExactAlarms()
    }
}
