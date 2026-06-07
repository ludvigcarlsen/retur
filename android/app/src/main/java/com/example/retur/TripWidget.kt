package com.example.retur

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalSize
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer

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

    // Responsive (not Exact) so the size-variant layouts are baked into one RemoteViews and the
    // launcher picks by actual size - this survives the runComposition() refresh push.
    override val sizeMode = SizeMode.Responsive(WIDGET_SIZE_BUCKETS)

    // Widget-picker preview (Android 15+): the real layout at the default (full) size.
    override val previewSizeMode = SizeMode.Responsive(setOf(DpSize(220.dp, 200.dp)))

    override suspend fun providePreview(context: Context, widgetCategory: Int) {
        provideContent { TripWidgetContent(context, WidgetRepository.previewState(), rounded = true) }
    }
}

@Composable
fun TripWidgetContent(context: Context, state: WidgetState, rounded: Boolean = false) {
    when (state) {
        is WidgetState.NoData -> CenteredMessage("Tap to get started!")
        is WidgetState.NoTrips -> CenteredMessage("No departures found")
        is WidgetState.Error -> CenteredMessage(state.message)
        is WidgetState.Success -> {
            val next = state.departures.first()
            val tall = LocalSize.current.height >= CONTROLS_MIN_HEIGHT
            Column(
                modifier = widgetSurface(rounded),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                FromToHeader(from = state.fromName, to = state.toName)
                Spacer(GlanceModifier.defaultWeight())
                TimeBlock(context, next.departureEpochMillis, showCountdown = tall)
                if (tall) {
                    Spacer(GlanceModifier.defaultWeight())
                    ModeChipRow(legs = next.legs, max = 3)
                    WidgetButtonRow(state.updatedAtMillis)
                }
            }
        }
    }
}
