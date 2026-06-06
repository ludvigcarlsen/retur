package com.example.retur

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Fires at a departure's time (scheduled by WidgetScheduler.scheduleRolloverAt) and
 * refreshes the widgets so the next-departure widget advances to the following trip
 * instead of letting its countdown run negative.
 */
class DepartureAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        WidgetScheduler.refreshNow(context.applicationContext)
    }
}
