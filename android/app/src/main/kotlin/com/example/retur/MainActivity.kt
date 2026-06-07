package com.example.retur

import android.os.Build
import android.os.Bundle
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.setWidgetPreviews
import io.flutter.embedding.android.FlutterActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Publish the live widget-picker previews (Android 15+). No system callback drives this,
        // so we push on app launch; the call is rate-limited by the platform, so failures are fine.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            CoroutineScope(Dispatchers.Default).launch {
                runCatching {
                    val manager = GlanceAppWidgetManager(applicationContext)
                    manager.setWidgetPreviews<TripWidget>()
                    manager.setWidgetPreviews<TripBoardWidget>()
                }
            }
        }
    }
}
