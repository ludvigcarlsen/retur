package com.example.retur

import android.content.SharedPreferences
import com.google.gson.Gson

data class TripData(
    val from: StopPlace,
    val to: StopPlace,
    val settings: TripSettings,
    val filter: TripFilter
) {
    companion object {
        fun fromSharedPreferences(prefs: SharedPreferences, key: String = "trip"): TripData? {
            val json = prefs.getString(key, null) ?: return null
            return try {
                Gson().fromJson(json, TripData::class.java)
            } catch (e: Exception) {
                null
            }
        }
    }
}

data class StopPlace(
    val id: String?,
    val name: String?,
    val latitude: Double,
    val longitude: Double
)

data class TripSettings(
    val isDynamicTrip: Boolean,
    val includeFirstWalk: Boolean
)

data class TripFilter(
    val not: ExcludeModes,
    val walkSpeed: Double
)

data class ExcludeModes(
    val transportModes: Set<String>
)

// --- Entur journey-planner v3 response models (mirror the GraphQL query) ---

data class EnturResponse(val data: EnturData?)

data class EnturData(val trip: EnturTrip?)

data class EnturTrip(
    val tripPatterns: List<TripPattern> = emptyList(),
    val fromPlace: NamedPlace?,
    val toPlace: NamedPlace?
)

data class TripPattern(
    val expectedStartTime: String?,
    val expectedEndTime: String?,
    val legs: List<Leg> = emptyList()
)

data class Leg(
    val mode: String?,
    val distance: Double?,
    val expectedStartTime: String?,
    val fromPlace: NamedPlace?,
    val line: Line?,
    val fromEstimatedCall: EstimatedCall?
)

data class NamedPlace(val name: String?)

data class Line(val id: String?, val publicCode: String?)

data class EstimatedCall(val destinationDisplay: DestinationDisplay?)

data class DestinationDisplay(val frontText: String?)

// --- Flattened view-models the widgets render from ---

data class LegInfo(
    val mode: String,
    val publicCode: String?,
    val destination: String?
)

data class Departure(
    val departureEpochMillis: Long,
    val arrivalEpochMillis: Long?,
    val fromName: String,
    val legs: List<LegInfo>
)