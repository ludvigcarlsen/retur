package io.github.ludvigcarlsen.retur

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import android.os.Bundle
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.setWidgetPreviews
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    // Reliable widget refresh for app-driven changes (e.g. the user edits the trip). Goes through
    // our runComposition() push instead of Glance's session update, which drops back-to-back
    // updates while its ~45s lock is held - hence the old "have to change the trip twice" bug.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "refresh" -> {
                        CoroutineScope(Dispatchers.Default).launch {
                            WidgetRepository.clearSwap(applicationContext)
                            WidgetRepository.refresh(applicationContext)
                            updateAllWidgets(applicationContext)
                        }
                        result.success(true)
                    }
                    "canPinWidget" -> result.success(canPinWidget())
                    "pinWidget" -> {
                        pinWidget(call.argument<String>("widget"))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // The OS forwards the request to the current launcher, which must support
    // pinning (API 26+). The launcher shows its own confirm dialog.
    private fun canPinWidget(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        return AppWidgetManager.getInstance(this).isRequestPinAppWidgetSupported
    }

    private fun pinWidget(which: String?) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = AppWidgetManager.getInstance(this)
        if (!manager.isRequestPinAppWidgetSupported) return
        val provider = if (which == "compact") {
            ComponentName(this, TripWidget::class.java)
        } else {
            ComponentName(this, TripBoardWidget::class.java)
        }
        manager.requestPinAppWidget(provider, null, null)
    }

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

    private companion object {
        const val WIDGET_CHANNEL = "io.github.ludvigcarlsen.retur/widgets"
    }
}
