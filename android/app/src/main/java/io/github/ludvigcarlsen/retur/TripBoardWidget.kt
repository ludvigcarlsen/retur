package io.github.ludvigcarlsen.retur

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

/** Departure-board widget showing the next few departures. */
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

    // Exact gives the real widget size in LocalSize, so the board fits as many rows as the height
    // allows. Survives the runComposition() push now that the push passes the widget's real size.
    override val sizeMode = SizeMode.Exact

    // Widget-picker preview (Android 15+): the real board at the default (full) size.
    override val previewSizeMode = SizeMode.Responsive(setOf(DpSize(220.dp, 200.dp)))

    override suspend fun providePreview(context: Context, widgetCategory: Int) {
        provideContent { TripBoardWidgetContent(context, WidgetRepository.previewState(), rounded = true) }
    }
}

private const val MAX_BOARD_ROWS = 10
private val BOARD_CHROME_TALL = 112.dp   // surface padding + header + the button row
private val BOARD_CHROME_SHORT = 64.dp   // surface padding + header (no controls)

// Width reserved for the time pill; legCap fits the legs to the rest (SizeMode.Exact real width).
private val BOARD_TIME_RESERVE = 60.dp
// A headsign costs ~this many slots; spare slots (beyond one per leg) buy that many headsigns.
private const val HEADSIGN_EXTRA_SLOTS = 2

@Composable
fun TripBoardWidgetContent(context: Context, state: WidgetState, rounded: Boolean = false) {
    when (state) {
        is WidgetState.NoData -> GetStartedButton()
        is WidgetState.Message -> MessageContent(state.fromName, state.toName, state.text, rounded)
        is WidgetState.Success -> {
            val height = LocalSize.current.height
            val controls = height >= CONTROLS_MIN_HEIGHT
            val chrome = if (controls) BOARD_CHROME_TALL else BOARD_CHROME_SHORT
            val rowStride = BOARD_PILL_HEIGHT + WIDGET_GAP
            val rowCount = (((height - chrome).value + WIDGET_GAP.value) / rowStride.value).toInt()
                .coerceIn(1, MAX_BOARD_ROWS)
                .coerceAtMost(state.departures.size)
            Column(
                modifier = widgetSurface(rounded),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                FromToHeader(from = state.fromName, to = state.toName)
                Spacer(GlanceModifier.height(WIDGET_GAP))
                // Compact layout centers the row(s) (flex above and below); taller layouts pin to top.
                if (!controls) Spacer(GlanceModifier.defaultWeight())
                // Glance caps a container at 10 children, so the inter-row gap is each row's top
                // padding, not a Spacer between them (N rows + N-1 spacers would exceed the cap).
                Column {
                    state.departures.take(rowCount).forEachIndexed { i, dep ->
                        BoardRow(context, dep, isFirst = i == 0)
                    }
                }
                Spacer(GlanceModifier.defaultWeight())
                if (controls) WidgetButtonRow(state.updatedAtMillis)
            }
        }
    }
}

@Composable
private fun BoardRow(context: Context, dep: Departure, isFirst: Boolean) {
    Row(
        modifier = GlanceModifier.fillMaxWidth().padding(top = if (isFirst) 0.dp else WIDGET_GAP),
        verticalAlignment = Alignment.CenterVertically
    ) {
        val legArea = LocalSize.current.width - BOARD_TIME_RESERVE
        val cap = legCap(legArea)
        // Walk legs are narrow and carry no headsign, so only line-coded legs count against the
        // budget; a headsign shows only when there's a spare slot (else it'd squeeze the code thin).
        val codedLegs = dep.legs.count { !it.publicCode.isNullOrEmpty() }
        val spareSlots = cap - codedLegs
        val headsignCount =
            if (spareSlots < 1) 0
            else (1 + (spareSlots - 1) / HEADSIGN_EXTRA_SLOTS).coerceAtMost(codedLegs)
        ModeChipRow(
            legs = dep.legs,
            legArea = legArea,
            headsignCount = headsignCount,
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
