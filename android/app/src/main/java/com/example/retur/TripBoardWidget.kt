package com.example.retur

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

/** Departure-board widget showing the next few departures (counterpart of iOS TripBoardWidget). */
class TripBoardWidget : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = TripBoardWidgetGlance()

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        WidgetScheduler.schedulePeriodic(context)
    }
}

class TripBoardWidgetGlance : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val state = WidgetRepository.getDepartures(context)
        provideContent { TripBoardWidgetContent(context, state) }
    }
}

private const val BOARD_ROWS = 3

@Composable
fun TripBoardWidgetContent(context: Context, state: WidgetState) {
    when (state) {
        is WidgetState.NoData -> CenteredMessage("Tap to get started!")
        is WidgetState.NoTrips -> CenteredMessage("No departures found")
        is WidgetState.Error -> CenteredMessage(state.message)
        is WidgetState.Success -> {
            Column(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .background(ColorProvider(WidgetColors.background))
                    .padding(12.dp)
            ) {
                Column(modifier = GlanceModifier.clickable(actionRunCallback<SwapAction>())) {
                    FromToHeader(from = state.fromName, to = state.toName)
                }
                Spacer(GlanceModifier.height(8.dp))
                Column(modifier = GlanceModifier.clickable(actionRunCallback<RefreshAction>())) {
                    state.departures.take(BOARD_ROWS).forEachIndexed { i, dep ->
                        if (i > 0) Spacer(GlanceModifier.height(6.dp))
                        BoardRow(context, dep)
                    }
                }
            }
        }
    }
}

@Composable
private fun BoardRow(context: Context, dep: Departure) {
    Row(
        modifier = GlanceModifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        ModeChip(dep.legs.first())
        Spacer(GlanceModifier.width(6.dp))
        Text(
            text = dep.legs.first().destination ?: "",
            maxLines = 1,
            style = TextStyle(color = ColorProvider(WidgetColors.muted)),
            modifier = GlanceModifier.defaultWeight()
        )
        Spacer(GlanceModifier.width(6.dp))
        Text(
            text = epochToHHmm(dep.departureEpochMillis),
            style = TextStyle(color = ColorProvider(WidgetColors.onBackground), fontWeight = FontWeight.Bold)
        )
        Spacer(GlanceModifier.width(6.dp))
        CountdownChronometer(context, dep.departureEpochMillis)
    }
}
