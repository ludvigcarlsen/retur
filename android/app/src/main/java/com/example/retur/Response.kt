package com.example.retur

data class Response(val data: ResponseData)

data class ResponseData(var trip: Trip)

data class Trip(
        var tripPatterns: List<TripPattern>,
        val fromPlace: Place,
        val toPlace: Place
)

data class Place(val name: String)

data class TripPattern(
        val expectedStartTime: String,
        val expectedEndTime: String,
        var legs: List<Leg>
)

data class Leg(
        val mode: TransportMode,
        val distance: Double,
        val expectedStartTime: String,
        val fromPlace: Place,
        val line: Line?
)

data class Line(val id: String, val publicCode: String?)
