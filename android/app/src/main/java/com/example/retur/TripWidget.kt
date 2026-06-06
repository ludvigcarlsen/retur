package com.example.retur

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

/** Single next-departure widget (counterpart of iOS TripWidget). */
class TripWidget : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = TripWidgetGlance()

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        WidgetScheduler.schedulePeriodic(context)
    }
}

class TripWidgetGlance : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val state = WidgetRepository.getDepartures(context)
        // When the soonest shown departure leaves, re-render to drop it.
        if (state is WidgetState.Success) {
            WidgetScheduler.scheduleExpiryRefresh(context, state.departures.first().departureEpochMillis)
        }
        provideContent { TripWidgetContent(context, state) }
    }
}

@Composable
fun TripWidgetContent(context: Context, state: WidgetState) {
    when (state) {
        is WidgetState.NoData -> CenteredMessage("Tap to get started!")
        is WidgetState.NoTrips -> CenteredMessage("No departures found")
        is WidgetState.Error -> CenteredMessage(state.message)
        is WidgetState.Success -> {
            val next = state.departures.first()
            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(ColorProvider(WidgetColors.background))
                    .padding(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Tap the from/to header to swap direction (like the iOS swap button).
                Column(modifier = GlanceModifier.clickable(actionRunCallback<SwapAction>())) {
                    FromToHeader(from = next.fromName.ifEmpty { state.fromName }, to = state.toName)
                }
                Spacer(GlanceModifier.defaultWeight())
                // Tap the time/countdown to refresh (like the iOS refresh button).
                Column(
                    modifier = GlanceModifier.clickable(actionRunCallback<RefreshAction>()),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = epochToHHmm(next.departureEpochMillis),
                        style = TextStyle(
                            color = ColorProvider(WidgetColors.onBackground),
                            fontWeight = FontWeight.Bold,
                            fontSize = 30.sp
                        )
                    )
                    CountdownChronometer(context, next.departureEpochMillis)
                }
                Spacer(GlanceModifier.defaultWeight())
                ModeChipRow(legs = next.legs, max = 3)
            }
        }
    }
}
