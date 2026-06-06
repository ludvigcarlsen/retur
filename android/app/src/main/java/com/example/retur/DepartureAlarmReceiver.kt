package com.example.retur

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Fires at a displayed departure's time (scheduled by WidgetScheduler.scheduleExpiryRefresh)
 * and re-renders the widgets straight from cache so the just-departed trip drops off and
 * the next one moves up. No network needed - dropping an expired departure is just a re-filter.
 */
class DepartureAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        android.util.Log.d("ReturWidget", "expiry alarm -> refresh")
        refreshWidgetsNow(context)
    }
}
