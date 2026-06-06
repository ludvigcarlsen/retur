package com.example.retur

import android.app.AlarmManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        maybeRequestExactAlarmPermission()
    }

    /**
     * Exact alarms let the widget drop a departure the instant it leaves. On Android 12+
     * the permission is user-granted, so ask once - but only if a widget is actually placed
     * and the permission is missing. If denied, the widget falls back to periodic/unlock refresh.
     */
    private fun maybeRequestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        val alarmManager = getSystemService(AlarmManager::class.java) ?: return
        if (alarmManager.canScheduleExactAlarms() || !hasPlacedWidget()) return

        val prefs = getSharedPreferences("retur_widget_cache", Context.MODE_PRIVATE)
        if (prefs.getBoolean("asked_exact_alarm", false)) return
        prefs.edit().putBoolean("asked_exact_alarm", true).apply()

        try {
            startActivity(
                Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:$packageName"))
            )
        } catch (e: Exception) {
            // Some OEMs don't expose this screen; rely on the fallback refresh path.
        }
    }

    private fun hasPlacedWidget(): Boolean {
        val manager = AppWidgetManager.getInstance(this)
        return listOf(TripWidget::class.java, TripBoardWidget::class.java).any { cls ->
            manager.getAppWidgetIds(ComponentName(this, cls)).isNotEmpty()
        }
    }
}
