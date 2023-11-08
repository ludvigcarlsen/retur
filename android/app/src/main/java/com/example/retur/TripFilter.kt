package com.example.retur

data class TripFilter(
        val not: ExcludeModes,
        val walkSpeed: Double
) {
/*
    companion object {
        fun fromJson(json: Map<String, Any>): TripFilter {
            return TripFilter(
                    ExcludeModes.fromJson(json["not"] as Map<String, Any>),
                    json["walkSpeed"] as Double
            )
        }
    }*/
}

data class ExcludeModes(
        val transportModes: Set<TransportMode>
) {

    /*companion object {
        fun fromJson(json: Map<String, Any>): ExcludeModes {
            return ExcludeModes(
                    json["transportModes"]?.map { TransportMode.fromJson(it) }?.toSet() ?: emptySet()
            )
        }
    }*/
}
