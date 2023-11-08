package com.example.retur

import com.google.gson.Gson
import okhttp3.Call
import okhttp3.Callback
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import java.io.IOException

class NetworkManager {
    private val baseURL = "https://api.entur.io/journey-planner/v3/graphql"
    private val client = OkHttpClient()
    private val gson = Gson()

    sealed class Result<out T> {
        data class Success<out T>(val data: T) : Result<T>()
        data class Failure(val exception: Exception) : Result<Nothing>()
    }

    fun getTrip(data: FlutterData, callback: (Result<com.example.retur.Response>) -> Unit) {
        val query = getQuery(data.from, data.to, data.filter)
        val payload = Payload(query = query)

        val request = Request.Builder()
                .url(baseURL)
                .post(gson.toJson(payload).toRequestBody("application/json".toMediaType()))
                .addHeader("ET-Client-Name", "ludvigcarlsen-retur")
                .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                e.printStackTrace()
                callback(Result.Failure(e))
            }

            override fun onResponse(call: Call, response: Response) {
                val responseBody = response.body?.string()
                val responseObj = gson.fromJson(responseBody, com.example.retur.Response::class.java)
                callback(Result.Success(responseObj))
            }
        })
    }

    private fun getQuery(from: StopPlace, to: StopPlace, filter: TripFilter): String {
        val notFilter = formatNotFilter(filter.not.transportModes)
        return """
            {
                trip(
                    from: {
                        place: "${from.id ?: ""}",
                        coordinates: {latitude: ${from.latitude}, longitude: ${from.longitude}},
                        name: "${from.name}"}
                    to: {
                        place: "${to.id ?: ""}",
                        coordinates: {latitude: ${to.latitude}, longitude: ${to.longitude}},
                        name: "${to.name}"}
                    filters: $notFilter
                    modes: {accessMode: foot, egressMode: foot}
                    walkSpeed: ${filter.walkSpeed / 3.6}
                ) {
                    tripPatterns {
                        expectedStartTime
                        expectedEndTime
                        legs {
                            mode
                            distance
                            expectedStartTime
                            fromPlace {
                                name
                            }
                            line {
                                id
                                publicCode
                            }
                        }
                    }
                    fromPlace {
                        name
                    }
                    toPlace {
                        name
                    }
                }
            }
        """
    }

    private fun formatNotFilter(modes: Set<TransportMode>): String {
        if (modes.isEmpty()) return "{}"
        val modesString = modes.joinToString(",") { """{transportMode: "${it.name}"}""" }
        return """{not: {transportModes: [$modesString]}"""
    }
}

data class Payload(val variables: String = "{}", val query: String)
