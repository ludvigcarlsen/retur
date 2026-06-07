package com.example.retur

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.Context
import androidx.glance.ExperimentalGlanceApi
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.runComposition
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Tap-to-refresh. Fetch + re-render run directly here, in the action's own coroutine:
 * the fetch is well under a second, comfortably inside the action window.
 */
class RefreshAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        WidgetRepository.refresh(context)
        updateAllWidgets(context)
    }
}

/** Swap departure/destination for the widget only (does not change the app's saved trip). */
class SwapAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        WidgetRepository.toggleSwap(context)
        WidgetRepository.refresh(context)
        updateAllWidgets(context)
    }
}

/**
 * Re-render every Retur widget instance (single + board).
 *
 * We compose the RemoteViews ourselves with runComposition() and push them straight through
 * AppWidgetManager, instead of GlanceAppWidget.updateAll(). updateAll() goes through Glance's
 * session manager, which holds a lock for ~45s after an update and silently drops any update
 * requested inside that window - so a second button tap a few seconds later updates the data
 * but never the screen. Pushing RemoteViews directly side-steps that lock and lands on every tap.
 */
@OptIn(ExperimentalGlanceApi::class)
suspend fun updateAllWidgets(context: Context) = withContext(Dispatchers.Main) {
    val glanceManager = GlanceAppWidgetManager(context)
    val appWidgetManager = AppWidgetManager.getInstance(context)

    suspend fun push(widget: GlanceAppWidget, provider: Class<out GlanceAppWidget>) {
        glanceManager.getGlanceIds(provider).forEach { glanceId ->
            runCatching {
                val remoteViews = widget.runComposition(context, glanceId).first()
                appWidgetManager.updateAppWidget(glanceManager.getAppWidgetId(glanceId), remoteViews)
            }
        }
    }

    push(TripWidgetGlance(), TripWidgetGlance::class.java)
    push(TripBoardWidgetGlance(), TripBoardWidgetGlance::class.java)
}

/**
 * Immediately re-render the widgets from a BroadcastReceiver (unlock / expiry alarm),
 * without going through WorkManager - WorkManager is deferrable and would delay the
 * refresh. goAsync() keeps the receiver alive for the short re-render.
 */
fun BroadcastReceiver.refreshWidgetsNow(context: Context) {
    val pending = goAsync()
    val app = context.applicationContext
    CoroutineScope(Dispatchers.Default).launch {
        try {
            updateAllWidgets(app)
        } finally {
            pending.finish()
        }
    }
}
