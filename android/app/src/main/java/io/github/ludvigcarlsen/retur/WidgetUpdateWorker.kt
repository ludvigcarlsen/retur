package io.github.ludvigcarlsen.retur

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters

/** Refetches departures and re-renders the widgets. Driven by WidgetScheduler. */
class WidgetUpdateWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result = try {
        WidgetRepository.refresh(applicationContext)
        updateAllWidgets(applicationContext)
        Result.success()
    } catch (e: Exception) {
        Result.retry()
    }
}
