package com.example.retur

data class FlutterData(
        val from: StopPlace,
        val to: StopPlace,
        val filter: TripFilter,
        val settings: TripSettings
)

data class StopPlace(
        val id: String?,
        val name: String?,
        val latitude: Double,
        val longitude: Double
)
