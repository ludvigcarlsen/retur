package com.example.retur

import android.content.Context
import com.google.gson.Gson
import es.antonborri.home_widget.HomeWidgetPlugin
import java.time.OffsetDateTime

/** Render state for the widgets, mirroring the iOS EntryType cases. */
sealed class WidgetState {
    data class Success(
        val departures: List<Departure>,
        val fromName: String,
        val toName: String
    ) : WidgetState()

    object NoData : WidgetState()      // no saved trip — open the app
    object NoTrips : WidgetState()     // saved trip, but Entur returned nothing
    data class Error(val message: String) : WidgetState()
}

/**
 * Reads the saved trip config (written by Flutter via home_widget), fetches
 * departures from Entur, and caches the response with a timestamp so frequent
 * refresh triggers (unlock, tap) don't hammer the network. Mirrors iOS CacheManager.
 */
object WidgetRepository {
    private const val CACHE_PREFS = "retur_widget_cache"
    private const val CACHE_KEY = "cached_response"
    private const val CACHE_TS_KEY = "cached_response_ts"
    private const val DEFAULT_MAX_AGE_MS = 60_000L
    private val gson = Gson()

    suspend fun getDepartures(context: Context, maxAgeMillis: Long = DEFAULT_MAX_AGE_MS): WidgetState {
        val config = TripData.fromSharedPreferences(HomeWidgetPlugin.getData(context))
            ?: return WidgetState.NoData

        val response = try {
            getCachedOrFetch(context, config, maxAgeMillis)
        } catch (e: Exception) {
            return WidgetState.Error(humanError(e))
        }

        val trip = response.data?.trip ?: return WidgetState.NoTrips
        if (trip.tripPatterns.isEmpty()) return WidgetState.NoTrips

        val now = System.currentTimeMillis()
        val departures = trip.tripPatterns
            .mapNotNull { toDeparture(it, includeFirstWalk = config.settings.includeFirstWalk) }
            .filter { it.departureEpochMillis > now } // never show a departure that already left
        if (departures.isEmpty()) return WidgetState.NoTrips

        return WidgetState.Success(
            departures = departures,
            fromName = trip.fromPlace?.name ?: config.from.name.orEmpty(),
            toName = trip.toPlace?.name ?: config.to.name.orEmpty()
        )
    }

    /** Force a fresh fetch regardless of cache age (used by tap-to-refresh). */
    suspend fun refresh(context: Context): WidgetState = getDepartures(context, maxAgeMillis = 0L)

    /** Drop the cached response (used after a swap changes from/to). */
    fun clearCache(context: Context) {
        context.getSharedPreferences(CACHE_PREFS, Context.MODE_PRIVATE).edit().clear().apply()
    }

    private suspend fun getCachedOrFetch(
        context: Context,
        config: TripData,
        maxAgeMillis: Long
    ): EnturResponse {
        val prefs = context.getSharedPreferences(CACHE_PREFS, Context.MODE_PRIVATE)
        val ts = prefs.getLong(CACHE_TS_KEY, 0L)
        val cached = prefs.getString(CACHE_KEY, null)
        if (cached != null && System.currentTimeMillis() - ts < maxAgeMillis) {
            runCatching { gson.fromJson(cached, EnturResponse::class.java) }
                .getOrNull()?.let { return it }
        }

        val fresh = EnturService.fetchTrip(config)
        prefs.edit()
            .putString(CACHE_KEY, gson.toJson(fresh))
            .putLong(CACHE_TS_KEY, System.currentTimeMillis())
            .apply()
        return fresh
    }

    private fun toDeparture(pattern: TripPattern, includeFirstWalk: Boolean): Departure? {
        var legs = pattern.legs
        if (!includeFirstWalk && legs.firstOrNull()?.mode == "foot") {
            legs = legs.drop(1)
        }
        if (legs.isEmpty()) return null

        val firstRealLeg = legs.first()
        val depMillis = parseIso(firstRealLeg.expectedStartTime ?: pattern.expectedStartTime)
            ?: return null

        return Departure(
            departureEpochMillis = depMillis,
            arrivalEpochMillis = parseIso(pattern.expectedEndTime),
            fromName = firstRealLeg.fromPlace?.name.orEmpty(),
            legs = legs.map {
                LegInfo(
                    mode = it.mode ?: "unknown",
                    publicCode = it.line?.publicCode,
                    destination = it.fromEstimatedCall?.destinationDisplay?.frontText
                )
            }
        )
    }

    private fun parseIso(iso: String?): Long? =
        iso?.let { runCatching { OffsetDateTime.parse(it).toInstant().toEpochMilli() }.getOrNull() }

    private fun humanError(e: Exception): String = when (e) {
        is java.net.UnknownHostException -> "No network connection"
        is java.net.SocketTimeoutException -> "Request timed out"
        else -> "Something went wrong"
    }
}
