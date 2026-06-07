package com.example.retur

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
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
     * Re-render right after the soonest shown departure leaves, so the expired trip drops off.
     * A stale departure only looks wrong while the screen is on, so an inexact, non-wakeup alarm
     * is enough: it fires promptly while the device is awake, and the unlock refresh covers the
     * user arriving at the home screen. No exact-alarm permission needed.
     */
    fun scheduleExpiryRefresh(context: Context, departureEpochMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, DepartureAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.set(AlarmManager.RTC, departureEpochMillis, pendingIntent)
    }
}
