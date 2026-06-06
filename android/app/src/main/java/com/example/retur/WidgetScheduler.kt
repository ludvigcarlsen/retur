package com.example.retur

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

/**
 * Schedules widget refreshes. WorkManager's 15-minute floor is the backstop;
 * the real freshness comes from refresh-on-unlock and tap-to-refresh, while the
 * Chronometer keeps ticking between refreshes.
 */
object WidgetScheduler {
    private const val PERIODIC_WORK = "retur_widget_periodic"
    private const val ONE_TIME_WORK = "retur_widget_refresh_now"

    private val networkConstraint = Constraints.Builder()
        .setRequiredNetworkType(NetworkType.CONNECTED)
        .build()

    /** Periodic backstop refresh (15-minute minimum imposed by the platform). */
    fun schedulePeriodic(context: Context) {
        val request = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(15, TimeUnit.MINUTES)
            .setConstraints(networkConstraint)
            .build()
        WorkManager.getInstance(context)
            .enqueueUniquePeriodicWork(PERIODIC_WORK, ExistingPeriodicWorkPolicy.KEEP, request)
    }

    /**
     * Re-render the widget right after a departure leaves, so the next-departure
     * widget rolls forward instead of its countdown ticking into the negative.
     * Uses an inexact alarm (no SCHEDULE_EXACT_ALARM permission needed).
     */
    fun scheduleRolloverAt(context: Context, departureEpochMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, DepartureAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        // +2s so the trip has clearly departed by the time we re-render.
        alarmManager.set(AlarmManager.RTC, departureEpochMillis + 2_000L, pendingIntent)
    }

    /** One-shot refresh (used on unlock and on departure rollover). */
    fun refreshNow(context: Context) {
        val request = OneTimeWorkRequestBuilder<WidgetUpdateWorker>()
            .setConstraints(networkConstraint)
            .build()
        WorkManager.getInstance(context)
            .enqueueUniqueWork(ONE_TIME_WORK, ExistingWorkPolicy.REPLACE, request)
    }
}
