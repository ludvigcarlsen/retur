import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:retur/models/trip_settings.dart';
import 'package:retur/models/tripdata.dart';
import 'package:retur/models/tripresponse.dart';
import 'package:retur/screens/search.dart';
import 'package:http/http.dart' as http;
import 'package:home_widget/home_widget.dart';
import 'package:retur/widgets/trip_settings_view.dart';
import 'package:retur/widgets/tripitemskeleton.dart';
import 'package:retur/widgets/modal_wrapper.dart';

import '../models/trip_filter.dart';
import '../utils/queries.dart';
import '../widgets/trip_filter_view.dart';
import '../widgets/tripinputcard.dart';
import '../widgets/tripitemcard.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  Future<TripResponse?>? tripResponse;
  TripFilter filter = TripFilter.def();
  TripSettings settings = TripSettings.def();
  StopPlace? from, to;
  bool isSaved = false;

  @override
  void initState() {
    HomeWidget.setAppGroupId('group.returwidget');
    super.initState();
    _loadTrip();
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

  Future<bool> _saveTrip() async {
    if (from == null || to == null) return false;
    final data = TripData(from!, to!, filter: filter);
    try {
      await HomeWidget.saveWidgetData<String>('trip', jsonEncode(data));
      return true;
    } on PlatformException catch (e) {
      debugPrint("Error saving trip. $e");
      return false;
    }
  }

  Future<bool> _updateWidget() async {
    try {
      HomeWidget.updateWidget(
          name: "TripWidgetProvider", iOSName: "TripWidget");

      return true;
    } on PlatformException catch (e) {
      debugPrint("Error updating widget. $e");
      return false;
    }
  }

  Future<bool> _saveAndUpdate() async {
    return await _saveTrip() && await _updateWidget();
  }

  Future _loadTrip() async {
    try {
      return Future.wait([
        HomeWidget.getWidgetData<String>('trip').then((value) {
          if (value == null) return;

          TripData t = TripData.fromJson(jsonDecode(value));
          setState(() {
            from = t.from;
            to = t.to;
            filter = t.filter;
            isSaved = true;
            tripResponse = getTrip();
          });
        }),
      ]);
    } on PlatformException catch (e) {
      debugPrint("Error loading trip. $e");
    }
  }

  Future<TripResponse?> getTrip() async {
    if (from == null || to == null) return null;
    setState(() => isSaved = false);
    final String baseUrl = Queries.journeyPlannerV3BaseUrl;
    final headers = Queries.headers;
    final String query = Queries.trip(from!, to!, filter);
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({'query': query}),
    );

    return TripResponse.fromJson(jsonDecode(response.body));
  }

  void onFilterUpdate(TripFilter? newFilter) {
    if (newFilter == null) return;
    setState(() {
      filter = newFilter;
      tripResponse = getTrip();
    });
  }

  void onSettingsUpdate(TripSettings? newSettings) {
    if (newSettings == null) return;
    settings = newSettings;
    print(newSettings!.includeFirstWalk);
    print(newSettings!.isDynamicTrip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        if (result != null) {
                          setState(() {
                            from = result;
                            tripResponse = getTrip();
                          });
                        }
                      },
                    ),
                    onToTap: () =>
                        _navigateSearch(context, to?.name).then((result) {
                      if (result != null) {
                        setState(() {
                          to = result;
                          tripResponse = getTrip();
                        });
                      }
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
                              color: const Color.fromARGB(255, 77, 78, 91),
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
                            title: "Journey filter",
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
                            title: "Journey settings",
                            child: TripSettingsView(
                              settings: TripSettings.from(settings),
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
              if (tripResponse == null)
                Container()
              else
                ReRunnableFutureBuilder(
                  tripResponse,
                  onRerun: () => getTrip,
                ),
              const SizedBox(height: 15.0),
              SaveButton(
                onPressed: () {
                  _saveAndUpdate().then(
                      (value) => value ? setState(() => isSaved = true) : null);
                },
                isSaved: isSaved,
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
  int flex;

  FlexButton(
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

class SaveButton extends StatefulWidget {
  final Function()? onPressed;
  final bool isSaved;

  const SaveButton({super.key, required this.onPressed, required this.isSaved});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  _SaveButtonState();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.isSaved ? Icons.favorite : Icons.favorite_outline,
                size: 20),
            const SizedBox(width: 5.0),
            Text(widget.isSaved ? "Saved!" : "Save"),
          ],
        ),
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
          padding: const MaterialStatePropertyAll(EdgeInsets.all(8)),
          minimumSize: const MaterialStatePropertyAll(Size.zero),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          backgroundColor:
              const MaterialStatePropertyAll(Color.fromARGB(255, 70, 79, 100))),
      onPressed: onPressed,
      child: const RotatedBox(quarterTurns: 1, child: Icon(Icons.sync_alt)),
    );
  }
}

class ReRunnableFutureBuilder extends StatelessWidget {
  final Future<TripResponse?>? _future;
  final Function onRerun;

  const ReRunnableFutureBuilder(this._future,
      {super.key, required this.onRerun});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Expanded(
            child: ListView.separated(
              itemCount: 2,
              itemBuilder: (context, index) => const TripCardSkeleton(),
              separatorBuilder: (context, index) => const SizedBox(height: 15),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return const Text("no data");
        }
        List<TripPattern> patterns = snapshot.data!.data.trip.tripPatterns;

        if (patterns.isEmpty) {
          return Text("Couldn't find any journeys");
        }
        return Expanded(
          child: ListView.builder(
            itemCount: patterns.length,
            itemBuilder: (context, index) {
              return TripCard(
                patterns: patterns[index],
              );
            },
          ),
        );
      },
    );
  }
}
