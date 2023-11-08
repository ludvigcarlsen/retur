package com.example.retur

import android.graphics.Color

enum class TransportMode(val displayName: String) {
    bus("bus"),
    coach("coach"),
    tram("tram"),
    rail("train"),
    metro("metro"),
    water("ferry"),
    air("airplane"),
    lift("lift"),
    foot("foot"),
    unknown("unknown");

    companion object {
        fun fromJson(s: String): TransportMode {
            return valueOf(s)
        }

        fun getColor(mode: String): Int {
            return transportColorMap[mode] ?: Color.rgb(148, 148, 148)
        }
    }
}

private val transportColorMap = mapOf(
        TransportMode.bus.name to Color.rgb(230, 0, 0),
        TransportMode.tram.name to Color.rgb(11, 145, 239),
        TransportMode.rail.name to Color.rgb(0, 48, 135),
        TransportMode.metro.name to Color.rgb(236, 112, 12),
        TransportMode.water.name to Color.rgb(104, 44, 136),
        TransportMode.foot.name to Color.rgb(82, 83, 93)
)

private val transportAssetMap = mapOf(
        TransportMode.bus.name to "assets/bus.svg",
        TransportMode.coach.name to "assets/bus.svg",
        TransportMode.tram.name to "assets/tram.svg",
        TransportMode.rail.name to "assets/rail.svg",
        TransportMode.metro.name to "assets/metro.svg",
        TransportMode.water.name to "assets/water.svg",
        TransportMode.air.name to "assets/air.svg",
        TransportMode.foot.name to "assets/foot.svg"
)
