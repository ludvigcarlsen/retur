package com.example.retur

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.updateAll
import com.google.gson.Gson
import es.antonborri.home_widget.HomeWidgetPlugin

/** Tap-to-refresh: force a fresh Entur fetch and re-render. Mirrors iOS RefreshIntent. */
class RefreshAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        WidgetRepository.refresh(context)
        updateAllWidgets(context)
    }
}

/** Tap-to-swap from/to. Persists to the shared prefs so the app reflects it too. Mirrors iOS SwapIntent. */
class SwapAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val prefs = HomeWidgetPlugin.getData(context)
        val json = prefs.getString("trip", null) ?: return
        val gson = Gson()
        val current = runCatching { gson.fromJson(json, TripData::class.java) }.getOrNull() ?: return

        val swapped = current.copy(from = current.to, to = current.from)
        prefs.edit().putString("trip", gson.toJson(swapped)).apply()

        WidgetRepository.clearCache(context)
        updateAllWidgets(context)
    }
}

/** Re-render every Retur widget instance (single + board). */
suspend fun updateAllWidgets(context: Context) {
    TripWidgetGlance().updateAll(context)
    TripBoardWidgetGlance().updateAll(context)
}
