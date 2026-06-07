package com.example.retur

import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL

/**
 * Fetches trip departures from Entur's journey-planner v3 GraphQL API.
 * Kotlin counterpart of the iOS widget's NetworkManager.swift — the widget
 * fetches on its own so it stays fresh without the app being open.
 */
object EnturService {
    private const val ENDPOINT = "https://api.entur.io/journey-planner/v3/graphql"
    private const val CLIENT_NAME = "ludvigcarlsen-retur"
    private val gson = Gson()

    suspend fun fetchTrip(config: TripData): EnturResponse = withContext(Dispatchers.IO) {
        val payload = gson.toJson(mapOf("query" to buildQuery(config)))
        val conn = (URL(ENDPOINT).openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            setRequestProperty("Content-Type", "application/json")
            setRequestProperty("ET-Client-Name", CLIENT_NAME)
            doOutput = true
            connectTimeout = 15_000
            readTimeout = 15_000
        }

        try {
            conn.outputStream.use { it.write(payload.toByteArray(Charsets.UTF_8)) }
            val code = conn.responseCode
            val stream = if (code in 200..299) conn.inputStream else conn.errorStream
            val body = stream?.bufferedReader()?.use { it.readText() } ?: ""
            if (code !in 200..299) throw IOException("HTTP $code: $body")
            gson.fromJson(body, EnturResponse::class.java)
        } finally {
            conn.disconnect()
        }
    }

    private fun buildQuery(config: TripData): String {
        val from = config.from
        val to = config.to
        val filter = config.filter
        return """
            {
              trip(
                from: { place: "${from.id ?: ""}", coordinates: {latitude: ${from.latitude}, longitude: ${from.longitude}}, name: "${escape(from.name)}" }
                to: { place: "${to.id ?: ""}", coordinates: {latitude: ${to.latitude}, longitude: ${to.longitude}}, name: "${escape(to.name)}" }
                filters: ${formatNotFilter(filter.not.transportModes)}
                modes: {accessMode: foot, egressMode: foot}
                walkSpeed: ${filter.walkSpeed / 3.6}
                numTripPatterns: 10
              ) {
                tripPatterns {
                  expectedStartTime
                  legs {
                    mode
                    expectedStartTime
                    fromPlace { name }
                    line { id publicCode }
                    fromEstimatedCall { destinationDisplay { frontText } }
                  }
                }
                fromPlace { name }
                toPlace { name }
              }
            }
        """.trimIndent()
    }

    private fun formatNotFilter(modes: Set<String>): String {
        if (modes.isEmpty()) return "{}"
        val joined = modes.joinToString(", ") { "{transportMode: $it}" }
        return "{not: {transportModes: [$joined]}}"
    }

    private fun escape(s: String?): String =
        (s ?: "").replace("\\", "\\\\").replace("\"", "\\\"")
}
