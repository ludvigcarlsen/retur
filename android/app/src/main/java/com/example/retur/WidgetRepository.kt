package com.example.retur

import android.content.Context
import com.google.gson.Gson
import es.antonborri.home_widget.HomeWidgetPlugin
import java.time.OffsetDateTime

/** Render state for the widgets. */
sealed class WidgetState {
    data class Success(
        val departures: List<Departure>,
        val fromName: String,
        val toName: String,
        val updatedAtMillis: Long
    ) : WidgetState()

    object NoData : WidgetState()      // no saved trip — open the app

    /** A saved trip exists (so we can still show the from/to header) but there's nothing to list:
     *  either Entur returned no departures, or the fetch failed with no cache to fall back on. */
    data class Message(val fromName: String, val toName: String, val text: String) : WidgetState()
}

/**
 * Reads the saved trip config (written by Flutter via home_widget), fetches
 * departures from Entur, and caches the response with a timestamp so frequent
 * refresh triggers (unlock, tap) don't hammer the network.
 */
object WidgetRepository {
    private const val CACHE_PREFS = "retur_widget_cache"
    private const val CACHE_KEY = "cached_response"
    private const val CACHE_TS_KEY = "cached_response_ts"
    private const val CACHE_CONFIG_KEY = "cached_config"
    private const val SWAP_KEY = "swapped"
    private const val DEFAULT_MAX_AGE_MS = 60_000L
    private val gson = Gson()

    private fun cachePrefs(context: Context) =
        context.getSharedPreferences(CACHE_PREFS, Context.MODE_PRIVATE)

    suspend fun getDepartures(context: Context, maxAgeMillis: Long = DEFAULT_MAX_AGE_MS): WidgetState {
        var config = TripData.fromSharedPreferences(HomeWidgetPlugin.getData(context))
            ?: return WidgetState.NoData
        // Widget-only direction swap (never written back to the app's saved trip).
        if (cachePrefs(context).getBoolean(SWAP_KEY, false)) {
            config = config.copy(from = config.to, to = config.from)
        }

        val from = config.from.name.orEmpty()
        val to = config.to.name.orEmpty()

        val response = try {
            getCachedOrFetch(context, config, maxAgeMillis)
        } catch (e: Exception) {
            return WidgetState.Message(from, to, humanError(e))
        }

        val now = System.currentTimeMillis()
        val departures = response.data?.trip?.tripPatterns.orEmpty()
            .mapNotNull { toDeparture(it, includeFirstWalk = config.settings.includeFirstWalk) }
            .filter { it.departureEpochMillis > now }
        if (departures.isEmpty()) return WidgetState.Message(from, to, "No departures found")

        return WidgetState.Success(
            departures = departures,
            fromName = from,
            toName = to,
            updatedAtMillis = cachePrefs(context).getLong(CACHE_TS_KEY, 0L)
        )
    }

    /** Force a fresh fetch regardless of cache age (used by tap-to-refresh). */
    suspend fun refresh(context: Context): WidgetState = getDepartures(context, maxAgeMillis = 0L)

    /** Representative sample shown in the widget picker (no network, no saved trip needed). */
    fun previewState(): WidgetState.Success {
        val now = System.currentTimeMillis()
        fun inMin(m: Int) = now + m * 60_000L
        return WidgetState.Success(
            departures = listOf(
                Departure(inMin(4), listOf(LegInfo("metro", "5", "Vestli"))),
                Departure(inMin(9), listOf(LegInfo("bus", "31", "Tonsenhagen"))),
                Departure(inMin(13), listOf(LegInfo("tram", "17", "Sinsen")))
            ),
            fromName = "Jernbanetorget",
            toName = "Carl Berners plass",
            updatedAtMillis = now
        )
    }

    /** Drop the widget-only direction swap. App-driven trip changes are authoritative, so the
     *  widget always mirrors the direction set in the app. */
    fun clearSwap(context: Context) {
        cachePrefs(context).edit().putBoolean(SWAP_KEY, false).apply()
    }

    /** Flip the widget-only direction swap, then drop the cache so the new direction is fetched. */
    fun toggleSwap(context: Context) {
        val prefs = cachePrefs(context)
        prefs.edit()
            .putBoolean(SWAP_KEY, !prefs.getBoolean(SWAP_KEY, false))
            .remove(CACHE_KEY)
            .remove(CACHE_TS_KEY)
            .apply()
    }

    private suspend fun getCachedOrFetch(
        context: Context,
        config: TripData,
        maxAgeMillis: Long
    ): EnturResponse {
        val prefs = cachePrefs(context)
        val ts = prefs.getLong(CACHE_TS_KEY, 0L)
        // The cache is only valid for the trip it was fetched for - otherwise changing the trip in
        // the app would keep showing the old trip's departures until the cache aged out.
        val configKey = gson.toJson(config)
        val cachedMatchesTrip = prefs.getString(CACHE_CONFIG_KEY, null) == configKey
        val cached = prefs.getString(CACHE_KEY, null)
        val cachedResponse = cached?.let {
            runCatching { gson.fromJson(it, EnturResponse::class.java) }.getOrNull()
        }

        // Same trip and fresh enough — serve cache without hitting the network.
        if (cachedResponse != null && cachedMatchesTrip &&
            System.currentTimeMillis() - ts < maxAgeMillis
        ) {
            return cachedResponse
        }

        return try {
            val fresh = EnturService.fetchTrip(config)
            prefs.edit()
                .putString(CACHE_KEY, gson.toJson(fresh))
                .putLong(CACHE_TS_KEY, System.currentTimeMillis())
                .putString(CACHE_CONFIG_KEY, configKey)
                .apply()
            fresh
        } catch (e: Exception) {
            // Offline / fetch failed: keep showing the last known departures (still filtered for
            // expiry), but only if they're for the current trip - never another trip's departures.
            if (cachedResponse != null && cachedMatchesTrip) cachedResponse else throw e
        }
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
