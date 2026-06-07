package com.example.retur

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
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
        // When the soonest shown departure leaves, re-render to drop it off the board.
        if (state is WidgetState.Success) {
            WidgetScheduler.scheduleExpiryRefresh(context, state.departures.first().departureEpochMillis)
        }
        provideContent { TripBoardWidgetContent(context, state) }
    }

    // Widget-picker preview (Android 15+): the real board with sample departures.
    override val previewSizeMode = SizeMode.Responsive(setOf(DpSize(180.dp, 110.dp), DpSize(250.dp, 180.dp)))

    override suspend fun providePreview(context: Context, widgetCategory: Int) {
        provideContent { TripBoardWidgetContent(context, WidgetRepository.previewState()) }
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
                    .fillMaxSize()
                    .background(ColorProvider(WidgetColors.background))
                    .cornerRadius(android.R.dimen.system_app_widget_background_radius)
                    .padding(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                FromToHeader(from = state.fromName, to = state.toName)
                Spacer(GlanceModifier.defaultWeight())
                Column {
                    state.departures.take(BOARD_ROWS).forEachIndexed { i, dep ->
                        if (i > 0) Spacer(GlanceModifier.height(6.dp))
                        BoardRow(context, dep, isFirst = i == 0)
                    }
                }
                Spacer(GlanceModifier.defaultWeight())
                WidgetButtonRow(state.updatedAtMillis)
            }
        }
    }
}

@Composable
private fun BoardRow(context: Context, dep: Departure, isFirst: Boolean) {
    Row(
        modifier = GlanceModifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        ModeChip(dep.legs.first(), showDestination = true)
        Spacer(GlanceModifier.defaultWeight())
        if (isFirst) {
            CountdownChronometer(context, dep.departureEpochMillis)
        } else {
            Text(
                text = epochToHHmm(dep.departureEpochMillis),
                style = TextStyle(color = ColorProvider(WidgetColors.muted), fontSize = 12.sp)
            )
        }
    }
}
