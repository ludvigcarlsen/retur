package com.example.retur

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.text.Text
import es.antonborri.home_widget.HomeWidgetPlugin


class TripWidget : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = TripWidgetGlance()
}

class TripWidgetGlance : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val tripData = TripData.fromSharedPreferences(widgetData)

        provideContent {
            TripWidgetContent(tripData)
        }
    }

    override suspend fun providePreview(context: Context, widgetCategory: Int) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val tripData = TripData.fromSharedPreferences(widgetData)

        provideContent {
            TripWidgetContent(tripData)
        }
    }
}

@Composable
fun TripWidgetContent(tripData: TripData?) {
    Column(
        modifier = GlanceModifier.fillMaxSize()
    ) {
        Text(text = tripData?.from?.name ?: "No from found")
        Text(text = tripData?.to?.name ?: "No to found")
    }
}