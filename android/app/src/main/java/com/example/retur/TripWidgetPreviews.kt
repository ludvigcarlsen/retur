package com.example.retur

import androidx.compose.runtime.Composable
import androidx.glance.preview.ExperimentalGlancePreviewApi
import androidx.glance.preview.Preview

private fun createMockTripData() = TripData(
    from = StopPlace(
        id = "NSR:StopPlace:58366",
        name = "Jernbanetorget",
        latitude = 59.911898,
        longitude = 10.75038
    ),
    to = StopPlace(
        id = "NSR:StopPlace:58404",
        name = "Nationaltheatret",
        latitude = 59.914994,
        longitude = 10.7322
    ),
    settings = TripSettings(
        isDynamicTrip = false,
        includeFirstWalk = false
    ),
    filter = TripFilter(
        not = ExcludeModes(
            transportModes = emptySet()
        ),
        walkSpeed = 4.2
    )
)

private fun createMockTripDataLongNames() = TripData(
    from = StopPlace(
        id = "NSR:StopPlace:12345",
        name = "Oslo Central Station Platform 19",
        latitude = 59.911898,
        longitude = 10.75038
    ),
    to = StopPlace(
        id = "NSR:StopPlace:67890",
        name = "Trondheim Central Station Terminal Building",
        latitude = 63.436123,
        longitude = 10.398341
    ),
    settings = TripSettings(
        isDynamicTrip = true,
        includeFirstWalk = true
    ),
    filter = TripFilter(
        not = ExcludeModes(
            transportModes = setOf("BUS", "METRO")
        ),
        walkSpeed = 3.5
    )
)


@OptIn(ExperimentalGlancePreviewApi::class)
@Preview(widthDp = 300, heightDp = 150)
@Composable
fun TripWidgetPreview() {
    val mockTripData = createMockTripData()
    TripWidgetContent(mockTripData)
}

@OptIn(ExperimentalGlancePreviewApi::class)
@Preview(widthDp = 300, heightDp = 150)
@Composable
fun TripWidgetEmptyPreview() {
    TripWidgetContent(null)
}

@OptIn(ExperimentalGlancePreviewApi::class)
@Preview(widthDp = 300, heightDp = 150)
@Composable
fun TripWidgetLongNamesPreview() {
    val mockTripData = createMockTripDataLongNames()
    TripWidgetContent(mockTripData)
}