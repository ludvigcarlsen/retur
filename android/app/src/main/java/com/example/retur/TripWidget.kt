package com.example.retur

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.os.SystemClock
import android.provider.Settings.Secure.getString
import android.widget.RemoteViews
import androidx.datastore.core.DataStore
import androidx.datastore.dataStore
import androidx.datastore.preferences.preferencesDataStore
import androidx.datastore.preferences.preferencesDataStoreFile
import com.google.gson.Gson
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Date

/**
 * Implementation of App Widget functionality.
 */

class TripWidget : AppWidgetProvider() {
    private val gson = Gson()

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {

       /* // TODO Check if cache has relevant departures
        val sharedPref = context.getSharedPreferences("trip_cache", Context.MODE_PRIVATE)
        val string: String? = sharedPref.getString("response", null)
        val cachedResponse: Response = Gson().fromJson(string, Response::class.java)

        if (cachedResponse == null) {
            for (appWidgetId in appWidgetIds) {
                // TODO check if cache is outdated
                updateAppWidget(context, appWidgetManager, appWidgetId, cachedResponse)
            }
            return
        }*/

        // If not, fetch new batch of departures
        val widgetData = HomeWidgetPlugin.getData(context)
        val json: String? = widgetData.getString("trip", null)
        val data: FlutterData = gson.fromJson(json, FlutterData::class.java)

        // TODO handle no widget data

        CoroutineScope(Dispatchers.IO).launch {
            NetworkManager().getTrip(data) { result -> when(result) {
                is NetworkManager.Result.Success -> {

                    // Update widgets
                    for (appWidgetId in appWidgetIds) {
                        updateAppWidget(context, appWidgetManager, appWidgetId, result.data)
                    }

                    // Cache result
                    //sharedPref.edit().putString("response", gson.toJson(result.data)).apply()
                }
                // TODO let user know error has occured
                is NetworkManager.Result.Failure -> {

                }
            }}
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    companion object {

    }
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, response: Response) {

    val views = RemoteViews(context.packageName, R.layout.trip_widget).apply {
        val startDate = parseIso8601String(response.data.trip.tripPatterns[0].expectedStartTime)
        val targetDate = Date.from(startDate.atZone(ZoneId.systemDefault()).toInstant())
        val timeDifference = targetDate.time - Date().time

        setTextViewText(R.id.widget_from, response.data.trip.fromPlace.name)
        setTextViewText(R.id.widget_to, response.data.trip.toPlace.name)
        setTextViewText(R.id.widget_start_time, formatDate(startDate))

        // TODO find a way of stopping when countdown reaches 0
        setChronometer(R.id.widget_countdown, SystemClock.elapsedRealtime().plus(timeDifference), null, true)
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

internal fun parseIso8601String(iso8601String: String): LocalDateTime {
    val dateTimeFormatter = DateTimeFormatter.ISO_DATE_TIME
    return LocalDateTime.parse(iso8601String, dateTimeFormatter)
}

fun formatDate(date: LocalDateTime) : String {
    val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")
    return date.format(timeFormatter)
}
