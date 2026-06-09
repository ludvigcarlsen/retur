package com.example.retur

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
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

    // Responsive (not Exact) so the size-variant layouts are baked into one RemoteViews and the
    // launcher picks by actual size - this survives the runComposition() refresh push.
    override val sizeMode = SizeMode.Responsive(WIDGET_SIZE_BUCKETS)

    // Widget-picker preview (Android 15+): the real board at the default (full) size.
    override val previewSizeMode = SizeMode.Responsive(setOf(DpSize(220.dp, 200.dp)))

    override suspend fun providePreview(context: Context, widgetCategory: Int) {
        provideContent { TripBoardWidgetContent(context, WidgetRepository.previewState(), rounded = true) }
    }
}

private const val BOARD_ROWS = 3

// Widgets can't measure available width at runtime, so the per-row leg count keys off the size
// bucket instead: one more leg on the wider bucket. "+N" covers whatever doesn't fit.
private val BOARD_LEGS_WIDE_MIN_WIDTH = 140.dp
private const val BOARD_LEGS_NARROW = 2
private const val BOARD_LEGS_WIDE = 3

@Composable
fun TripBoardWidgetContent(context: Context, state: WidgetState, rounded: Boolean = false) {
    when (state) {
        is WidgetState.NoData -> CenteredMessage("Tap to get started!")
        is WidgetState.Message -> MessageContent(state.fromName, state.toName, state.text, rounded)
        is WidgetState.Success -> {
            val tall = LocalSize.current.height >= CONTROLS_MIN_HEIGHT
            Column(
                modifier = widgetSurface(rounded),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                FromToHeader(from = state.fromName, to = state.toName)
                Spacer(GlanceModifier.defaultWeight())
                Column {
                    state.departures.take(if (tall) BOARD_ROWS else 1).forEachIndexed { i, dep ->
                        if (i > 0) Spacer(GlanceModifier.height(WIDGET_GAP))
                        BoardRow(context, dep, isFirst = i == 0)
                    }
                }
                if (tall) {
                    Spacer(GlanceModifier.defaultWeight())
                    WidgetButtonRow(state.updatedAtMillis)
                }
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
        val cap = if (LocalSize.current.width >= BOARD_LEGS_WIDE_MIN_WIDTH) BOARD_LEGS_WIDE else BOARD_LEGS_NARROW
        ModeChipRow(
            legs = dep.legs,
            cap = cap,
            showDestUntil = 2,
            modifier = GlanceModifier.defaultWeight(),
            bounded = true
        )
        Spacer(GlanceModifier.width(LEG_GAP))
        Box(
            modifier = GlanceModifier
                .height(BOARD_PILL_HEIGHT)
                .background(ColorProvider(WidgetColors.chipSurface))
                .cornerRadius(5.dp)
                .clickable(actionRunCallback<RefreshAction>())
                .padding(horizontal = 8.dp),
            contentAlignment = Alignment.Center
        ) {
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
}
