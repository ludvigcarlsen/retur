@file:OptIn(ExperimentalGlancePreviewApi::class)

package com.example.retur

import androidx.compose.runtime.Composable
import androidx.glance.LocalContext
import androidx.glance.preview.ExperimentalGlancePreviewApi
import androidx.glance.preview.Preview

/**
 * Android Studio previews for each widget state, so they can be flipped through in the preview
 * pane without deploying or killing the network. Debug-only (the glance-preview dependencies are
 * debugImplementation).
 *
 * Caveat: the big-time countdown uses AndroidRemoteViews, which does NOT render in the IDE preview
 * pane — so the Success previews show everything except the live ticking time. The message and
 * no-trip states use no RemoteViews and render fully. Use a device for the live countdown.
 */

private const val FROM = "Jernbanetorget"
private const val TO = "Carl Berners plass"

@Preview(widthDp = 250, heightDp = 200)
@Composable
fun SingleSuccessPreview() {
    TripWidgetContent(LocalContext.current, WidgetRepository.previewState(), rounded = true)
}

@Preview(widthDp = 250, heightDp = 200)
@Composable
fun BoardSuccessPreview() {
    TripBoardWidgetContent(LocalContext.current, WidgetRepository.previewState(), rounded = true)
}

@Preview(widthDp = 250, heightDp = 200)
@Composable
fun NoConnectionPreview() {
    TripWidgetContent(LocalContext.current, WidgetState.Message(FROM, TO, "No network connection"), rounded = true)
}

@Preview(widthDp = 250, heightDp = 200)
@Composable
fun NoDeparturesPreview() {
    TripBoardWidgetContent(LocalContext.current, WidgetState.Message(FROM, TO, "No departures found"), rounded = true)
}

@Preview(widthDp = 250, heightDp = 200)
@Composable
fun NoTripPreview() {
    TripWidgetContent(LocalContext.current, WidgetState.NoData, rounded = true)
}

// Smaller sizes exercise the responsive layout: short height (< 150dp) drops the controls/countdown,
// narrow width (< 120dp) drops the "Updated" label and crops the destination.

@Preview(widthDp = 200, heightDp = 110)
@Composable
fun SingleShortPreview() {
    TripWidgetContent(LocalContext.current, WidgetRepository.previewState(), rounded = true)
}

@Preview(widthDp = 200, heightDp = 110)
@Composable
fun BoardShortPreview() {
    TripBoardWidgetContent(LocalContext.current, WidgetRepository.previewState(), rounded = true)
}

@Preview(widthDp = 110, heightDp = 200)
@Composable
fun SingleNarrowPreview() {
    TripWidgetContent(LocalContext.current, WidgetRepository.previewState(), rounded = true)
}

@Preview(widthDp = 200, heightDp = 110)
@Composable
fun ErrorShortPreview() {
    TripWidgetContent(LocalContext.current, WidgetState.Message(FROM, TO, "No network connection"), rounded = true)
}

@Preview(widthDp = 110, heightDp = 200)
@Composable
fun ErrorNarrowPreview() {
    TripWidgetContent(LocalContext.current, WidgetState.Message(FROM, TO, "No network connection"), rounded = true)
}

@Preview(widthDp = 110, heightDp = 110)
@Composable
fun ErrorSmallestPreview() {
    TripWidgetContent(LocalContext.current, WidgetState.Message(FROM, TO, "No network connection"), rounded = true)
}
