import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retur/models/favourite.dart';
import 'package:retur/models/searchresponse.dart';
import 'package:retur/models/tripresponse.dart';
import 'package:retur/screens/search.dart';
import 'package:http/http.dart' as http;
import 'package:home_widget/home_widget.dart';

import '../utils/queries.dart';
import '../utils/transportmodes.dart';
import '../widgets/tripfilter.dart';
import '../widgets/tripinputcard.dart';
import '../widgets/tripitemcard.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  late Future<TripResponse?> tripResponse = getTrip();
  Set<TransportMode> excludeFilter = {};
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
    print("test");
    if (from == null || to == null) return;
    final data = TripData(from!, to!, excludeFilter.map((e) => e.name).toSet());

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
          });
        })
      ]);
    } on PlatformException catch (e) {
      debugPrint("Error loading trip. $e");
    }
  }

  Future<TripResponse?> getTrip() async {
    if (from == null || to == null) return null;
    final String baseUrl = Queries().journeyPlannerV3BaseUrl;
    final headers = Queries().headers;
    final String query = Queries().trip(from!, to!, excludeFilter);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({'query': query}),
    );

    return TripResponse.fromJson(jsonDecode(response.body));
  }

  void onFilterUpdate(Set<TransportMode>? filter) {
    if (filter == null) {
      return;
    }

    setState(() => excludeFilter = filter);
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
              TripInputCard(
                fromName: from?.name,
                toName: to?.name,
                onFromTap: () => _navigateSearch(context, from?.name).then(
                  (result) {
                    if (result != null) setState(() => from = result);
                  },
                ),
                onToTap: () => _navigateSearch(context, to?.name).then(
                  (result) {
                    if (result != null) setState(() => to = result);
                  },
                ),
                onTripSelected: () => setState(
                  () {
                    tripResponse = getTrip();
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet<dynamic>(
                          useSafeArea: true,
                          context: context,
                          builder: (BuildContext context) {
                            return TripFilter(exclude: Set.from(excludeFilter));
                          },
                        ).then((filter) => onFilterUpdate(filter));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.tune, size: 20),
                          SizedBox(width: 5.0),
                          Text("Filter")
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => {
                        _saveAndUpdate(),
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.favorite_outline, size: 20),
                          SizedBox(width: 5.0),
                          Text("Save")
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              FutureBuilder(
                future: tripResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    List<TripPatterns>? patterns =
                        snapshot.data!.data?.trip?.tripPatterns;
                    if (patterns == null) {
                      return Text("Something went wrong");
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
                  }
                  return Container();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
