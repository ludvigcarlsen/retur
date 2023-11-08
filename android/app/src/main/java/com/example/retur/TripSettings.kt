package com.example.retur

data class TripSettings(
        val isDynamicTrip: Boolean,
        val includeFirstWalk: Boolean
) {
    companion object {
        fun fromJson(json: Map<String, Any>): TripSettings {
            return TripSettings(
                    json["isDynamicTrip"] as Boolean,
                    json["includeFirstWalk"] as Boolean
            )
        }
    }
}
