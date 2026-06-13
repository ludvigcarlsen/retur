package io.github.ludvigcarlsen.retur

import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.LocalSize
import androidx.glance.ImageProvider
import androidx.glance.action.Action
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.AndroidRemoteViews
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.layout.wrapContentHeight
import androidx.glance.layout.wrapContentSize
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

/** Widget palette, mirrored from the Flutter app (main.dart / transportmodes.dart). */
object WidgetColors {
    val background = Color(0xFF212025)
    val onBackground = Color(0xFFFFFFFF)
    val muted = Color(0xB3FFFFFF) // white @ 70%
    val chipFallback = Color(0xFF949494)
    val chipSurface = Color(0x4052535D) // foot color @ 25%, the gray pill behind the legs
    val buttonBackground = Color(0xFF444F64)
    val buttonForeground = Color(0xFF519AFF) // accent blue of the button glyphs (ic_swap/ic_refresh)
    val divider = Color(0x1FFFFFFF) // faint hairline above the button row

    private val modeColors = mapOf(
        "bus" to Color(0xFFE60000),
        "coach" to Color(0xFFE60000),
        "tram" to Color(0xFF0B91EF),
        "rail" to Color(0xFF003087),
        "metro" to Color(0xFFEC700C),
        "water" to Color(0xFF682C88),
        "foot" to Color(0xFF52535D),
    )

    fun forMode(mode: String): Color = modeColors[mode] ?: chipFallback
}

/** Maps an Entur transport mode to its white glyph drawable. */
fun modeIconRes(mode: String): Int = when (mode) {
    "bus", "coach" -> R.drawable.ic_mode_bus
    "tram" -> R.drawable.ic_mode_tram
    "rail" -> R.drawable.ic_mode_rail
    "metro" -> R.drawable.ic_mode_metro
    "water" -> R.drawable.ic_mode_water
    "air" -> R.drawable.ic_mode_air
    "foot" -> R.drawable.ic_mode_foot
    else -> R.drawable.ic_mode_bus
}

private val hhmm: DateTimeFormatter = DateTimeFormatter.ofPattern("HH:mm")

fun epochToHHmm(millis: Long): String =
    Instant.ofEpochMilli(millis).atZone(ZoneId.systemDefault()).format(hhmm)

/** Standalone live countdown (used for the board's first row). */
@Composable
fun CountdownChronometer(context: Context, targetEpochMillis: Long) {
    val base = SystemClock.elapsedRealtime() + (targetEpochMillis - System.currentTimeMillis())
    val rv = RemoteViews(context.packageName, R.layout.widget_countdown).apply {
        setChronometer(R.id.widget_countdown, base, null, true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            setChronometerCountDown(R.id.widget_countdown, true)
        }
    }
    AndroidRemoteViews(remoteViews = rv, modifier = GlanceModifier.wrapContentSize())
}

/**
 * Departure time + live countdown in one RemoteViews so the spacing between them is
 * controllable; the Chronometer ticks on the system clock with no widget refresh.
 */
@Composable
fun TimeBlock(context: Context, targetEpochMillis: Long, showCountdown: Boolean = true) {
    val base = SystemClock.elapsedRealtime() + (targetEpochMillis - System.currentTimeMillis())
    val rv = RemoteViews(context.packageName, R.layout.widget_time).apply {
        setTextViewText(R.id.widget_time, epochToHHmm(targetEpochMillis))
        if (showCountdown) {
            setViewVisibility(R.id.widget_chronometer, View.VISIBLE)
            setChronometer(R.id.widget_chronometer, base, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                setChronometerCountDown(R.id.widget_chronometer, true)
            }
        } else {
            setViewVisibility(R.id.widget_chronometer, View.GONE)
            // No countdown below, so trim the time's font-descent space so it sits flush.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                setViewLayoutMargin(R.id.widget_time, RemoteViews.MARGIN_BOTTOM, -5f, TypedValue.COMPLEX_UNIT_DIP)
            }
        }
    }
    AndroidRemoteViews(
        remoteViews = rv,
        modifier = GlanceModifier.wrapContentHeight().clickable(actionRunCallback<RefreshAction>())
    )
}

/** The colored line badge: white mode glyph + line code on the mode color. Hugs its content. */
@Composable
fun LineBadge(leg: LegInfo) {
    val background = if (leg.mode == "foot") GlanceModifier
        else GlanceModifier.background(ColorProvider(WidgetColors.forMode(leg.mode)))
    Row(
        modifier = background
            .cornerRadius(5.dp)
            .padding(3.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(
            provider = ImageProvider(modeIconRes(leg.mode)),
            contentDescription = leg.mode,
            modifier = GlanceModifier.size(13.dp)
        )
        if (!leg.publicCode.isNullOrEmpty()) {
            Spacer(GlanceModifier.width(2.dp))
            Text(
                text = leg.publicCode,
                style = TextStyle(color = ColorProvider(Color.White), fontWeight = FontWeight.Bold, fontSize = 12.sp)
            )
        }
    }
}

/**
 * Transport-mode card: the colored line badge on a gray pill, with the destination
 * next to it. Every pill takes a uniform height and an icon-only leg (e.g. walk) is a square. In a
 * width-bounded row (bounded) the destination flexes and truncates so following badges aren't
 * clipped; otherwise the chip hugs its content.
 */
@Composable
fun ModeChip(
    leg: LegInfo,
    showDestination: Boolean = false,
    bounded: Boolean = false,
    modifier: GlanceModifier = GlanceModifier
) {
    val destination = if (showDestination) leg.destination?.takeIf(String::isNotEmpty) else null
    val iconOnly = destination == null && leg.publicCode.isNullOrEmpty()
    val base = (if (iconOnly) modifier.size(BOARD_PILL_HEIGHT) else modifier.height(BOARD_PILL_HEIGHT))
        .background(ColorProvider(WidgetColors.chipSurface))
        .cornerRadius(5.dp)
    if (iconOnly) {
        Box(modifier = base, contentAlignment = Alignment.Center) { LineBadge(leg) }
    } else {
        Row(modifier = base, verticalAlignment = Alignment.CenterVertically) {
            LineBadge(leg)
            if (destination != null) {
                Spacer(GlanceModifier.width(4.dp))
                Text(
                    text = destination,
                    maxLines = 1,
                    modifier = (if (bounded) GlanceModifier.defaultWeight() else GlanceModifier).padding(end = 5.dp),
                    style = TextStyle(color = ColorProvider(WidgetColors.onBackground), fontSize = 11.sp)
                )
            }
        }
    }
}

val BOARD_PILL_HEIGHT = 24.dp
val WIDGET_GAP = 8.dp
val LEG_GAP = 4.dp
// Leg chips are fit to the available width ~one slot each; the "+N" card is a touch narrower.
val LEG_SLOT_WIDTH = 44.dp
val OVERFLOW_CARD_WIDTH = 28.dp
// Cap so a row stays under Glance's 10-children limit (each leg is a chip + a gap Spacer).
const val MAX_LEG_CHIPS = 4

/** How many leg chips fit in [legArea], clamped to the container limit. */
fun legCap(legArea: Dp): Int = (legArea.value / LEG_SLOT_WIDTH.value).toInt().coerceIn(1, MAX_LEG_CHIPS)

/** "+N" overflow pill for the legs that don't fit. */
@Composable
fun OverflowCard(count: Int) {
    Box(
        modifier = GlanceModifier
            .size(BOARD_PILL_HEIGHT)
            .background(ColorProvider(WidgetColors.buttonBackground))
            .cornerRadius(5.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "+$count",
            style = TextStyle(color = ColorProvider(WidgetColors.buttonForeground), fontWeight = FontWeight.Bold, fontSize = 11.sp)
        )
    }
}

/**
 * The journey's legs as chips, fit to [legArea]. All legs when they fit, otherwise leg chips plus a
 * "+N" card for the rest. A bounded (board) row collapses to just the first leg when too narrow for
 * a leg + card; an unbounded (single-widget) row has no time pill beside it, so it keeps the extra
 * chip whenever the card still fits.
 *
 * @param legArea width available for the chips (widget width minus the time pill or padding)
 * @param headsignCount show the destination text for the first N legs that actually have one
 */
@Composable
fun ModeChipRow(
    legs: List<LegInfo>,
    legArea: Dp,
    headsignCount: Int,
    modifier: GlanceModifier = GlanceModifier,
    bounded: Boolean = false
) {
    Row(
        modifier = modifier.clickable(actionStartActivity<MainActivity>()),
        verticalAlignment = Alignment.CenterVertically
    ) {
        val cap = legCap(legArea)
        val shown: Int
        val hidden: Int
        when {
            legs.size <= cap -> { shown = legs.size; hidden = 0 }
            bounded && cap <= 1 -> { shown = 1; hidden = 0 }
            bounded -> { shown = cap - 1; hidden = legs.size - (cap - 1) }
            else -> {
                // No time pill beside these legs, so keep the last chip if the "+N" card still fits.
                val keepLast = legArea.value - cap * LEG_SLOT_WIDTH.value >= OVERFLOW_CARD_WIDTH.value
                shown = (if (keepLast) cap else cap - 1).coerceAtLeast(1)
                hidden = legs.size - shown
            }
        }
        var headsignsLeft = headsignCount
        legs.take(shown).forEachIndexed { i, leg ->
            if (i > 0) Spacer(GlanceModifier.width(LEG_GAP))
            val showDest = headsignsLeft > 0 && !leg.destination.isNullOrEmpty()
            if (showDest) headsignsLeft--
            // Headsign chips flex so Android truncates them to fit; compact chips stay content-sized.
            ModeChip(
                leg = leg,
                showDestination = showDest,
                bounded = bounded,
                modifier = if (bounded && showDest) GlanceModifier.defaultWeight() else GlanceModifier
            )
        }
        if (hidden > 0) {
            Spacer(GlanceModifier.width(LEG_GAP))
            OverflowCard(hidden)
        }
    }
}

/** Rounded-square icon button. */
@Composable
private fun IconButton(iconRes: Int, description: String, action: Action) {
    Box(modifier = GlanceModifier.clickable(action)) {
        Box(
            modifier = GlanceModifier
                .size(32.dp)
                .cornerRadius(8.dp)
                .background(ColorProvider(WidgetColors.buttonBackground)),
            contentAlignment = Alignment.Center
        ) {
            Image(
                provider = ImageProvider(iconRes),
                contentDescription = description,
                modifier = GlanceModifier.size(16.dp)
            )
        }
    }
}

/** Below this widget height the bottom controls row is dropped to save vertical space. */
val CONTROLS_MIN_HEIGHT = 150.dp

/** Below this width the bottom row shows no timestamp at all (only the buttons fit). */
val UPDATED_MIN_WIDTH = 120.dp
/** Below this the timestamp drops its "Updated " prefix to just the time, so it never truncates. */
val UPDATED_LABEL_MIN_WIDTH = 150.dp

/**
 * Swap (widget-only) and refresh buttons (bottom-right) under a faint divider, with a last-updated
 * timestamp on the left that degrades (full label -> time -> hidden) as the width shrinks.
 */
@Composable
fun WidgetButtonRow(updatedAtMillis: Long) {
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        Box(GlanceModifier.fillMaxWidth().height(1.dp).background(ColorProvider(WidgetColors.divider))) {}
        Spacer(GlanceModifier.height(8.dp))
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.Bottom) {
            val width = LocalSize.current.width
            val stamp = when {
                updatedAtMillis <= 0 || width < UPDATED_MIN_WIDTH -> null
                width >= UPDATED_LABEL_MIN_WIDTH -> "Updated ${epochToHHmm(updatedAtMillis)}"
                else -> epochToHHmm(updatedAtMillis)
            }
            if (stamp != null) {
                Text(
                    text = stamp,
                    maxLines = 1,
                    modifier = GlanceModifier.defaultWeight(),
                    style = TextStyle(color = ColorProvider(WidgetColors.muted), fontSize = 10.sp)
                )
            } else {
                Spacer(GlanceModifier.defaultWeight())
            }
            IconButton(R.drawable.ic_swap, "Swap direction", actionRunCallback<SwapAction>())
            Spacer(GlanceModifier.width(WIDGET_GAP))
            IconButton(R.drawable.ic_refresh, "Refresh", actionRunCallback<RefreshAction>())
        }
    }
}

/**
 * Root surface for a widget. Placed widgets are clipped to the system corner radius by the
 * launcher (API 31+), so they must NOT self-round (that double-rounds and notches the corners);
 * only the picker preview, which gets no launcher clip, rounds itself.
 */
fun widgetSurface(rounded: Boolean): GlanceModifier {
    val base = GlanceModifier.fillMaxSize().background(ColorProvider(WidgetColors.background))
    return (if (rounded) base.cornerRadius(android.R.dimen.system_app_widget_background_radius) else base)
        .padding(12.dp)
}

/** No-saved-trip state: a button into the app to set one up. */
@Composable
fun GetStartedButton() {
    Box(modifier = widgetSurface(rounded = false), contentAlignment = Alignment.Center) {
        Box(
            modifier = GlanceModifier
                .background(ColorProvider(WidgetColors.buttonBackground))
                .cornerRadius(8.dp)
                .clickable(actionStartActivity<MainActivity>())
                .padding(horizontal = 14.dp, vertical = 9.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Get started",
                style = TextStyle(
                    color = ColorProvider(WidgetColors.buttonForeground),
                    fontWeight = FontWeight.Bold,
                    fontSize = 13.sp
                )
            )
        }
    }
}

/**
 * Shown when a trip is configured but there's nothing to list (empty result, or a failed fetch
 * with no cache): keeps the from/to header and the buttons so the user can retry with refresh.
 */
@Composable
fun MessageContent(fromName: String, toName: String, message: String, rounded: Boolean) {
    val tall = LocalSize.current.height >= CONTROLS_MIN_HEIGHT
    Column(
        modifier = widgetSurface(rounded),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        FromToHeader(from = fromName, to = toName)
        Spacer(GlanceModifier.defaultWeight())
        Text(
            text = message,
            maxLines = 2,
            style = TextStyle(color = ColorProvider(WidgetColors.muted), fontSize = 13.sp, textAlign = TextAlign.Center)
        )
        Spacer(GlanceModifier.defaultWeight())
        if (tall) WidgetButtonRow(updatedAtMillis = 0L)
    }
}

/** from/to header with the dot/pin column and connecting line. */
@Composable
fun FromToHeader(from: String, to: String) {
    Box(
        modifier = GlanceModifier.fillMaxWidth().clickable(actionRunCallback<SwapAction>()),
        contentAlignment = Alignment.Center
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Image(ImageProvider(R.drawable.ic_dot), contentDescription = null, modifier = GlanceModifier.size(8.dp))
                Box(GlanceModifier.width(1.dp).height(8.dp).background(ColorProvider(Color(0xFF4D4E5B)))) {}
                Image(
                    ImageProvider(R.drawable.ic_pin), contentDescription = null,
                    modifier = GlanceModifier.width(8.dp).height(11.dp)
                )
            }
            Spacer(GlanceModifier.width(8.dp))
            Column {
                Text(
                    from, maxLines = 1,
                    style = TextStyle(color = ColorProvider(WidgetColors.onBackground), fontWeight = FontWeight.Bold, fontSize = 12.sp)
                )
                Spacer(GlanceModifier.height(2.dp))
                Text(to, maxLines = 1, style = TextStyle(color = ColorProvider(WidgetColors.muted), fontSize = 12.sp))
            }
        }
    }
}
