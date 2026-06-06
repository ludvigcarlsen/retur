# Android widget implementation plan

Bring the Android home-screen widgets to approximate parity with iOS. Branch: `android-widget`.

## Goal & parity summary

Match the iOS `TripWidget` (single next departure) and `TripBoardWidget` (3 upcoming departures): from/to header, big departure clock-time, a **live-ticking countdown**, colored transport-mode chips (icon + line code) + destination, tap-to-refresh and tap-to-swap.

| iOS mechanism | Android approach | Parity |
|---|---|---|
| `Text(date, style: .timer)` live countdown | `Chronometer` + `setChronometerCountDown(true)` (ticks on system clock, no refresh) | Full |
| WidgetKit timeline auto-advance | No equivalent → board shows several at once + refresh on unlock / tap / WorkManager | ~90% |
| AppIntents refresh/swap buttons | Glance `actionRunCallback` | Full |
| Widget extension fetches Entur (Swift) | Kotlin fetches Entur (mirror `NetworkManager.swift`) | Full |

## Key architectural decisions

1. **Keep Jetpack Glance** for layout (matches the WIP, modern, low boilerplate) and **embed a `Chronometer` via `AndroidRemoteViews`** for the one thing Glance can't do natively — the live countdown.
2. **Fetch in Kotlin, not Flutter.** The widget must stay fresh without opening the app, like the iOS extension. Flutter already writes the trip *config* to the shared `trip` prefs key; Kotlin reads it, fetches departures, caches, renders. **No Flutter/Dart changes needed for v1** (the WIP already added `androidName:` to `HomeWidget.updateWidget`).
3. **Two Glance widgets**, both reading the same cache: `TripWidget` (single) and `TripBoardWidget` (board). Convert the WIP's classic-RemoteViews `TripBoardWidget` to Glance for consistency.
4. **Refresh, in order of value:** `ACTION_USER_PRESENT` static receiver (fires on every unlock) → tap-to-refresh → WorkManager 15-min backstop. Glance `updatePeriodMillis = 0` (we manage). **Not** exact alarms (denied by default on Android 14+).
5. **Staleness guard** mirroring iOS `CacheManager`: on a refresh trigger, only hit the network if the cache is older than ~60s; otherwise just re-render (which drops past departures). Bounds network usage given frequent unlocks.

## Data flow

```
Flutter app  ──writes 'trip' config (from/to/filter/settings)──▶  shared prefs (HomeWidgetPreferences)
                                                                        │
USER_PRESENT / tap / WorkManager / widget-add  ─────────────────▶  Kotlin WidgetRepository
                                                                        │ reads config
                                                                        ▼
                                                          EnturService (GraphQL POST) ──▶ cache JSON + timestamp
                                                                        │
                                                                        ▼
                                                   Glance render: rows + Chronometer(base=departureEpoch, countDown=true)
```

The `trip` prefs schema (already produced by Flutter, already mirrored by `TripWidgetModels.kt`):
`{ from:StopPlace, to:StopPlace, filter:{not:{transportModes:[...]}, walkSpeed}, settings:{isDynamicTrip, includeFirstWalk} }`.

## Work breakdown (file by file)

### Phase 1 — Data layer (Kotlin networking, mirrors iOS)
- **`EnturService.kt`** (new) — build the GraphQL trip query (port `NetworkManager.getQuery`, the richer iOS field set: `fromPlace.name`, `fromEstimatedCall.destinationDisplay.frontText`, `line.publicCode`, per-leg `expectedStartTime`, `numTripPatterns: 10`); POST to `https://api.entur.io/journey-planner/v3/graphql` with `ET-Client-Name: ludvigcarlsen-retur`; parse with Gson. `suspend fun` (coroutines). Use `HttpURLConnection` (no new HTTP dep) or OkHttp.
- **`TripWidgetModels.kt`** (extend) — add response models (`TripResponse/Data/Trip/TripPattern/Leg/Line/Place/EstimatedCall/DestinationDisplay`) + a flat `Departure` view-model (`departureEpochMillis, lineCode, mode, destination, fromName, toName`). Keep existing config models.
- **`WidgetRepository.kt`** (new) — `getCachedOrFetch(maxAgeSeconds)`: read `trip` config via `HomeWidgetPlugin.getData`, return fresh cache or fetch+cache (key `cached_trip_android`). Apply `includeFirstWalk` (drop leading foot leg). Return a sealed `Result` (Standard / NoData / NoTrips / Error) like iOS `EntryType`.
- **`AndroidManifest.xml`** — add `<uses-permission android:name="android.permission.INTERNET"/>` (required for the Kotlin fetch; not currently present).
- **`build.gradle`** — add `androidx.work:work-runtime-ktx`, `kotlinx-coroutines-android`. Gson + Glance already present.
- **Verify:** log a successful fetch + parse from a worker/test.

### Phase 2 — Single `TripWidget` (Glance + Chronometer)
- **`TripWidget.kt`** (rewrite) — `provideGlance`: load → `getCachedOrFetch` → render by state. Standard layout: from/to with dot/pin column, big `HH:mm`, the countdown, mode chips. States noData/noTrips/error mirror iOS messages ("Tap to get started!", "No departures found", "Tap to refresh").
- **`layout/widget_chronometer.xml`** (new) — a bare `<Chronometer>`; embedded via `AndroidRemoteViews`. Set base via `System.currentTimeMillis()`→elapsedRealtime offset, `setChronometerCountDown(true)`, start.
- **`colors.xml` / `dimens.xml`** — widget bg `#212025`, chip colors from `TransportMode.transportColorMap`, button colors (already partly scaffolded by the WIP).
- **Verify:** add widget on emulator, countdown ticks down second-by-second with no refresh.

### Phase 3 — Interactivity
- **`WidgetActions.kt`** (new) — `RefreshAction` (force refetch + `updateAll`) and `SwapAction` (swap from/to in the `trip` prefs, persist so the app reflects it, refetch) as `ActionCallback`s. Wire to taps on the time area (refresh) and from/to area (swap), mirroring iOS.

### Phase 4 — Board `TripBoardWidget`
- **`TripBoardWidget.kt`** (rewrite, classic→Glance) — `Column` of 3 rows; each row: line chip + destination + `HH:mm` + its own Chronometer. Reuses repository + chip + chronometer composables.
- **`xml/trip_board_widget_info.xml`** — keep sizing/preview; `updatePeriodMillis = 0`.

### Phase 5 — Refresh orchestration
- **`UserPresentReceiver.kt`** (new) — `BroadcastReceiver` for `android.intent.action.USER_PRESENT`, registered **statically** in the manifest; on unlock, if widgets exist, trigger refresh (re-render + refetch if stale).
- **`WidgetUpdateWorker.kt`** (new) — `CoroutineWorker`, periodic 15 min, refetch + `updateAll`. Enqueue on first widget add and on boot (`RECEIVE_BOOT_COMPLETED`).
- **Manifest** — register the receiver + boot receiver.

### Phase 6 — Icons & visual polish
- Convert the mode SVGs (`assets/bus.svg`, `tram.svg`, `rail.svg`, `metro.svg`, `water.svg`, `air.svg`, `foot.svg`) to Android **vector drawables** for the chips (Android can't use Flutter SVG assets directly). v1 fallback: color-only chips with the line code, icons added after.
- Match spacing/typography to the iOS small/medium layouts.

### Phase 7 — Verify
- `./gradlew assembleDebug`, run on emulator (API 34): render, ticking, tap-refresh, tap-swap, unlock-refresh, periodic worker. `flutter analyze` clean. Confirm the iOS build still green (no shared regressions).

## Open questions / risks
- **Countdown format:** Chronometer shows `MM:SS` / `H:MM:SS` — same as iOS `style: .timer`. No "4 min" word form. Acceptable / matches iOS.
- **Network on unlock:** mitigated by the ~60s staleness guard; tune if needed.
- **INTERNET permission** must survive the release manifest merge (debug adds it automatically; release may not).
- **Swap persistence:** writing config back from Kotlin must target the same prefs file `home_widget` uses (`HomeWidgetPreferences`) so the app stays in sync.
- **Real-time delay:** countdown targets the cached `expectedStartTime`; live delays only reflect on next fetch — same behavior as iOS between fetches.

## Out of scope (v1)
- Exact-alarm per-departure advance (permission-gated, fragile).
- Lockscreen/keyguard-specific layouts beyond defaults.
- The pre-existing `must_be_immutable` Dart lint refactors (tracked separately).
