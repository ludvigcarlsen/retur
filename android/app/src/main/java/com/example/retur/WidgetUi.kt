package com.example.retur

import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.Action
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
    val chipSurface = Color(0x3352535D) // foot color @ 20%, the gray pill behind the line (matches iOS)
    val buttonBackground = Color(0xFF444F64) // iOS widget button background
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

/** Maps an Entur transport mode to its white glyph drawable (mirrors the iOS asset set). */
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
fun TimeBlock(context: Context, targetEpochMillis: Long) {
    val base = SystemClock.elapsedRealtime() + (targetEpochMillis - System.currentTimeMillis())
    val rv = RemoteViews(context.packageName, R.layout.widget_time).apply {
        setTextViewText(R.id.widget_time, epochToHHmm(targetEpochMillis))
        setChronometer(R.id.widget_chronometer, base, null, true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            setChronometerCountDown(R.id.widget_chronometer, true)
        }
    }
    AndroidRemoteViews(remoteViews = rv, modifier = GlanceModifier.wrapContentHeight())
}

/**
 * Transport-mode card matching iOS: a colored chip (white mode glyph + line code) sitting
 * on a gray pill, with the destination next to it. Everything vertically centered.
 */
@Composable
fun ModeChip(leg: LegInfo, showDestination: Boolean = false) {
    Row(
        modifier = GlanceModifier
            .background(ColorProvider(WidgetColors.chipSurface))
            .cornerRadius(5.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            modifier = GlanceModifier
                .background(ColorProvider(WidgetColors.forMode(leg.mode)))
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
        if (showDestination && !leg.destination.isNullOrEmpty()) {
            Spacer(GlanceModifier.width(4.dp))
            Text(
                text = leg.destination,
                maxLines = 1,
                modifier = GlanceModifier.padding(end = 5.dp),
                style = TextStyle(color = ColorProvider(WidgetColors.onBackground), fontSize = 11.sp)
            )
        }
    }
}

@Composable
fun ModeChipRow(legs: List<LegInfo>, max: Int) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        val showDest = legs.size == 1 // iOS shows the destination only for single-leg trips
        legs.take(max).forEachIndexed { i, leg ->
            if (i > 0) Spacer(GlanceModifier.width(4.dp))
            ModeChip(leg, showDestination = showDest)
        }
        if (legs.size > max) {
            Spacer(GlanceModifier.width(4.dp))
            Text("+${legs.size - max}", style = TextStyle(color = ColorProvider(WidgetColors.muted), fontSize = 11.sp))
        }
    }
}

/** Rounded-square icon button using the iOS widget button colors. */
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

/**
 * "Updated HH:mm" (bottom-left) plus the swap (widget-only) and refresh buttons (bottom-right),
 * under a faint divider.
 */
@Composable
fun WidgetButtonRow(updatedAtMillis: Long) {
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        Spacer(GlanceModifier.height(8.dp))
        Box(GlanceModifier.fillMaxWidth().height(1.dp).background(ColorProvider(WidgetColors.divider))) {}
        Spacer(GlanceModifier.height(8.dp))
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.Bottom) {
            if (updatedAtMillis > 0) {
                Text(
                    text = "Updated ${epochToHHmm(updatedAtMillis)}",
                    style = TextStyle(color = ColorProvider(WidgetColors.muted), fontSize = 10.sp)
                )
            }
            Spacer(GlanceModifier.defaultWeight())
            IconButton(R.drawable.ic_swap, "Swap direction", actionRunCallback<SwapAction>())
            Spacer(GlanceModifier.width(8.dp))
            IconButton(R.drawable.ic_refresh, "Refresh", actionRunCallback<RefreshAction>())
        }
    }
}

/** Centered message used for the no-data / no-trips / error states. */
@Composable
fun CenteredMessage(message: String) {
    Box(
        modifier = GlanceModifier.fillMaxSize().background(ColorProvider(WidgetColors.background)).padding(12.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(message, style = TextStyle(color = ColorProvider(WidgetColors.onBackground)))
    }
}

/** from/to header with the dot/pin column and connecting line, centered like the iOS widgets. */
@Composable
fun FromToHeader(from: String, to: String) {
    Box(modifier = GlanceModifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Image(ImageProvider(R.drawable.ic_dot), contentDescription = null, modifier = GlanceModifier.size(8.dp))
                Box(GlanceModifier.width(1.dp).height(10.dp).background(ColorProvider(Color(0xFF4D4E5B)))) {}
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
                Spacer(GlanceModifier.height(4.dp))
                Text(to, maxLines = 1, style = TextStyle(color = ColorProvider(WidgetColors.muted), fontSize = 12.sp))
            }
        }
    }
}
