package com.example.retur

import android.content.Context
import android.os.Build
import android.os.SystemClock
import android.widget.RemoteViews
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceModifier
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
import androidx.glance.layout.padding
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

/** A colored transport-mode chip showing the line public code (icons come later). */
@Composable
fun ModeChip(leg: LegInfo) {
    Box(
        modifier = GlanceModifier
            .background(ColorProvider(WidgetColors.forMode(leg.mode)))
            .cornerRadius(5.dp)
            .padding(horizontal = 6.dp, vertical = 3.dp)
    ) {
        Text(
            text = leg.publicCode ?: leg.mode.uppercase(),
            style = TextStyle(
                color = ColorProvider(Color.White),
                fontWeight = FontWeight.Bold
            )
        )
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

/** "from → to" header row. */
@Composable
fun FromToHeader(from: String, to: String) {
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        Text(
            from,
            style = TextStyle(color = ColorProvider(WidgetColors.onBackground), fontWeight = FontWeight.Bold)
        )
        Text(to, style = TextStyle(color = ColorProvider(WidgetColors.muted)))
    }
}
