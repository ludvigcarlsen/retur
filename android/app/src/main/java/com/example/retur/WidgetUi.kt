package com.example.retur

import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.appwidget.AndroidRemoteViews
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

/**
 * Live countdown to [targetEpochMillis] via a Chronometer embedded in Glance. It ticks
 * on the system clock with no widget refresh, so the time-to-departure stays accurate
 * between refreshes (unlike a static "in X min", which goes stale). An exact alarm
 * re-renders at the departure so it advances to the next trip rather than ticking negative.
 */
@Composable
fun CountdownChronometer(context: Context, targetEpochMillis: Long) {
    val base = SystemClock.elapsedRealtime() + (targetEpochMillis - System.currentTimeMillis())
    val rv = RemoteViews(context.packageName, R.layout.widget_chronometer).apply {
        setChronometer(R.id.widget_chronometer, base, null, true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            setChronometerCountDown(R.id.widget_chronometer, true)
        }
    }
    AndroidRemoteViews(remoteViews = rv)
}

/** A colored transport-mode chip: white mode glyph + line public code (matches iOS TransportModeCard). */
@Composable
fun ModeChip(leg: LegInfo) {
    Row(
        modifier = GlanceModifier
            .background(ColorProvider(WidgetColors.forMode(leg.mode)))
            .cornerRadius(5.dp)
            .padding(horizontal = 4.dp, vertical = 3.dp),
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
                style = TextStyle(color = ColorProvider(Color.White), fontWeight = FontWeight.Bold)
            )
        }
    }
}

@Composable
fun ModeChipRow(legs: List<LegInfo>, max: Int) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        legs.take(max).forEachIndexed { i, leg ->
            if (i > 0) Spacer(GlanceModifier.width(4.dp))
            ModeChip(leg)
        }
        if (legs.size > max) {
            Spacer(GlanceModifier.width(4.dp))
            Text("+${legs.size - max}", style = TextStyle(color = ColorProvider(WidgetColors.muted)))
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

/** from/to header with the dot/pin column and connecting line, like the iOS widgets. */
@Composable
fun FromToHeader(from: String, to: String) {
    Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
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
                style = TextStyle(color = ColorProvider(WidgetColors.onBackground), fontWeight = FontWeight.Bold)
            )
            Spacer(GlanceModifier.height(4.dp))
            Text(to, maxLines = 1, style = TextStyle(color = ColorProvider(WidgetColors.muted)))
        }
    }
}
