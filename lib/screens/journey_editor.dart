import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:retur/models/trip_settings.dart';
import 'package:retur/models/journey.dart';
import 'package:retur/models/tripresponse.dart';
import 'package:retur/screens/search.dart';
import 'package:http/http.dart' as http;
import 'package:home_widget/home_widget.dart';
import 'package:retur/widgets/pull_refresh_state.dart';
import 'package:retur/widgets/trip_settings_view.dart';
import 'package:retur/widgets/modal_wrapper.dart';

import '../models/trip_filter.dart';
import '../utils/location_service.dart';
import '../utils/queries.dart';
import '../widgets/trip_filter_view.dart';
import '../widgets/tripinputcard.dart';

class JourneyEditor extends StatefulWidget {
  /// Edits an existing [journey], or starts blank when [isNew]. Pops with the
  /// saved [Journey] so the caller (the Journeys list) can persist it.
  const JourneyEditor({super.key, this.journey, this.isNew = false});

  final Journey? journey;
  final bool isNew;

  @override
  State<JourneyEditor> createState() => _JourneyEditorState();
}

class _JourneyEditorState extends State<JourneyEditor> {
  Future<TripResponse?>? tripResponse;
  TripFilter filter = TripFilter.def();
  TripSettings settings = TripSettings.def();
  StopPlace? from, to;
  String? _id; // carried through so the journey keeps its identity

  StreamSubscription<Position>? _positionSubscription;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.medium,
    distanceFilter: 500,
  );

  @override
  void initState() {
    HomeWidget.setAppGroupId('group.returwidget');
    super.initState();
    final journey = widget.journey;
    if (journey != null) {
      _id = journey.id;
      from = journey.from;
      to = journey.to;
      filter = journey.filter;
      settings = journey.settings;
      tripResponse = getTrip();
      _togglePositionStreamSubscription();
    }
  }

  Future<StopPlace?> _navigateSearch(
      BuildContext context, String? initial) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Search(locationName: initial),
      ),
    );
  }

  Journey? _currentData() {
    if (from == null || to == null) return null;
    return Journey(from!, to!, settings: settings, filter: filter, id: _id);
  }

  static const _widgetChannel =
      MethodChannel('io.github.ludvigcarlsen.retur/widgets');

  Future<bool> _forceUpdate() async {
    try {
      if (Platform.isAndroid) {
        // Glance's session update drops back-to-back refreshes; go through the native
        // runComposition push so a trip change always lands (and refetches departures).
        await _widgetChannel.invokeMethod('refresh');
      } else {
        HomeWidget.updateWidget(
            name: "TripWidgetProvider",
            iOSName: "TripWidget",
            androidName: "TripWidget");

        HomeWidget.updateWidget(
            name: "TripBoardWidgetProvider",
            iOSName: "TripBoardWidget",
            androidName: "TripBoardWidget");
      }

      return true;
    } on PlatformException catch (e) {
      debugPrint("Error updating widget. $e");
      return false;
    }
  }

  Future<TripResponse?> getTrip() async {
    if (from == null || to == null) return null;
    //setState(() => isSaved = false);
    final String baseUrl = Queries.journeyPlannerV3BaseUrl;
    final headers = Queries.headers;
    final String query = Queries.trip(from!, to!, filter);
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({'query': query}),
    );

    return TripResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  void onFilterUpdate(TripFilter? newFilter) {
    if (newFilter == null || filter.equals(newFilter)) return;

    setState(() {
      filter = newFilter;
      tripResponse = getTrip();
    });
  }

  void onSettingsUpdate(TripSettings? newSettings) {
    if (newSettings == null || settings.equals(newSettings)) {
      return;
    }

    settings = newSettings;
    _togglePositionStreamSubscription();
  }

  void _togglePositionStreamSubscription() async {
    if (settings.isDynamicTrip &&
        await LocationService.locationPermissionGranted()) {
      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen(
        (Position? position) {
          if (position == null || from == null || to == null) return;

          final distance = Geolocator.distanceBetween(to!.latitude,
              to!.longitude, position.latitude, position.longitude);
          Journey data;

          data = distance < 500
              ? Journey(to!, from!, filter: filter, settings: settings)
              : Journey(from!, to!, filter: filter, settings: settings);
          HomeWidget.saveWidgetData<String>('trip', jsonEncode(data));
          _forceUpdate();
        },
      );
    } else {
      _positionSubscription?.cancel();
    }
  }

  Future<bool> _onDynamicTripToggle(bool value) async {
    return value ? await LocationService.requestLocationPermission() : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.isNew ? "New journey" : "Edit journey")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  TripInputCard(
                    fromName: from?.name,
                    toName: to?.name,
                    onFromTap: () => _navigateSearch(context, from?.name).then(
                      (result) {
                        if (result == null) {
                          return;
                        }

                        setState(() {
                          from = result;
                          tripResponse = getTrip();
                        });
                      },
                    ),
                    onToTap: () =>
                        _navigateSearch(context, to?.name).then((result) {
                      if (result == null) {
                        return;
                      }

                      setState(() {
                        to = result;
                        tripResponse = getTrip();
                      });
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            SvgPicture.asset('assets/dot.svg', height: 13),
                            Container(
                              width: 2,
                              height: 32, // TODO dynamic solution
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            SvgPicture.asset(
                              'assets/pin.svg',
                              height: 18,
                            )
                          ],
                        ),
                        const Spacer(),
                        SwapButton(
                          onPressed: () {
                            StopPlace? temp = from;
                            setState(() {
                              from = to;
                              to = temp;
                              tripResponse = getTrip();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlexButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        useSafeArea: true,
                        context: context,
                        builder: (BuildContext context) {
                          return ModalWrapper(
                            child: TripFilterView(
                                current: TripFilter.from(filter)),
                          );
                        },
                      ).then((newFilter) {
                        onFilterUpdate(newFilter);
                      });
                    },
                    text: "Filter",
                    child: const Icon(Icons.tune, size: 20),
                  ),
                  const SizedBox(width: 15.0),
                  FlexButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        useSafeArea: true,
                        context: context,
                        builder: (BuildContext context) {
                          return ModalWrapper(
                            child: TripSettingsView(
                              settings: TripSettings.from(settings),
                              onDynamicTripToggle: _onDynamicTripToggle,
                            ),
                          );
                        },
                      ).then((value) => onSettingsUpdate(value));
                    },
                    text: "Settings",
                    child: const Icon(Icons.settings, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              if (tripResponse != null)
                Expanded(
                    child: PullRefreshPage(
                        futureNumbersList: tripResponse!, getTrip: getTrip)),
              const SizedBox(height: 15.0),
              if (tripResponse == null) const Spacer(),
              SaveButton(
                onPressed: () {
                  final data = _currentData();
                  if (data == null) return;
                  Navigator.pop(context, data); // list persists & decides active
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlexButton extends StatelessWidget {
  final String text;
  final Widget child;
  final Function()? onPressed;
  final int flex;

  const FlexButton(
      {super.key,
      this.flex = 1,
      required this.onPressed,
      required this.text,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            child,
            const SizedBox(width: 5.0),
            Text(text),
          ],
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final Function()? onPressed;

  const SaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Text("Save"),
      ),
    );
  }
}

class SwapButton extends StatelessWidget {
  final Function()? onPressed;
  const SwapButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.secondaryContainer)),
      onPressed: onPressed,
      child: const RotatedBox(quarterTurns: 1, child: Icon(Icons.sync_alt)),
    );
  }
}
