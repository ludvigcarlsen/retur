package io.github.ludvigcarlsen.retur

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
import androidx.glance.layout.height

/** Single next-departure widget. */
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

    // Exact gives the real widget size in LocalSize, so the bottom row can show its full "Updated"
    // label when wide. Survives the runComposition() push now that the push passes the real size.
    override val sizeMode = SizeMode.Exact

    // Widget-picker preview (Android 15+): the real layout at the default (full) size.
    override val previewSizeMode = SizeMode.Responsive(setOf(DpSize(220.dp, 200.dp)))

    override suspend fun providePreview(context: Context, widgetCategory: Int) {
        provideContent { TripWidgetContent(context, WidgetRepository.previewState(), rounded = true) }
    }
}

// The single widget's leg row spans the full content width (no time pill beside it), so reserve
// only the surface padding.
private val SINGLE_LEG_RESERVE = 24.dp

@Composable
fun TripWidgetContent(context: Context, state: WidgetState, rounded: Boolean = false) {
    when (state) {
        is WidgetState.NoData -> GetStartedButton()
        is WidgetState.Message -> MessageContent(state.fromName, state.toName, state.text, rounded)
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
                    ModeChipRow(
                        legs = next.legs,
                        legArea = LocalSize.current.width - SINGLE_LEG_RESERVE,
                        headsignCount = if (next.legs.size == 1) 1 else 0
                    )
                    Spacer(GlanceModifier.height(8.dp))
                    WidgetButtonRow(state.updatedAtMillis)
                }
            }
        }
    }
}
