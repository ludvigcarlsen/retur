import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:retur/models/tripdata.dart';
import 'package:retur/models/tripresponse.dart';
import 'package:retur/screens/search.dart';
import 'package:http/http.dart' as http;
import 'package:home_widget/home_widget.dart';

import '../models/filter.dart';
import '../utils/queries.dart';
import '../widgets/tripfilter.dart';
import '../widgets/tripinputcard.dart';
import '../widgets/tripitemcard.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  Future<TripResponse?>? tripResponse;
  Filter filter = Filter.def();
  StopPlace? from, to;

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

  Future _saveTrip() async {
    if (from == null || to == null) return;
    final data = TripData(from!, to!, filter: filter);

    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>('trip', jsonEncode(data)),
      ]);
    } on PlatformException catch (e) {
      debugPrint('Error sending data. $e');
    }
  }

  Future _updateWidget() async {
    try {
      return HomeWidget.updateWidget(
          name: "TripWidgetProvider", iOSName: "TripWidget");
    } on PlatformException catch (e) {
      debugPrint('Error updating widget. $e');
    }
  }

  Future _saveAndUpdate() async {
    await _saveTrip();
    await _updateWidget();
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

  void onFilterUpdate(Filter? newFilter) {
    if (newFilter != null) {
      setState(() {
        filter = newFilter;
        tripResponse = getTrip();
      });
    }
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
                children: [
                  ExpandedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        useSafeArea: true,
                        context: context,
                        builder: (BuildContext context) {
                          return TripFilter(current: Filter.from(filter));
                        },
                      ).then((newFilter) {
                        onFilterUpdate(newFilter);
                      });
                    },
                    text: "Filter",
                    icon: const Icon(Icons.tune, size: 20),
                  ),
                  const SizedBox(width: 15.0),
                  ExpandedButton(
                    onPressed: () => _saveAndUpdate(),
                    text: "Save",
                    icon: const Icon(Icons.favorite_outline, size: 20),
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
                )
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandedButton extends StatelessWidget {
  final String text;
  final Icon icon;
  final Function()? onPressed;
  const ExpandedButton(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 5.0),
            Text(text),
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
          return const Text("Loading...");
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
