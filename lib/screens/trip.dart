import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:retur/models/searchresponse.dart';
import 'package:retur/models/tripresponse.dart';
import 'package:retur/screens/search.dart';
import 'package:http/http.dart' as http;
import 'package:retur/widgets/locationitemcard.dart';
import 'package:retur/widgets/tripfilter.dart';
import 'package:retur/widgets/tripitemcard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/queries.dart';
import '../utils/transportmodes.dart';
import '../widgets/tripinputcard.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  Future<TripResponse>? tripResponse;
  Set<TransportMode> excludeFilter = {};
  Feature? from;
  Feature? to;

  Future<Feature?> _navigateSearch(
      BuildContext context, String? initial) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Search(locationName: initial),
      ),
    );
  }

  Future<TripResponse> getTrip() async {
    final String baseUrl = Queries().journeyPlannerV3BaseUrl;
    final headers = Queries().headers;
    final String query;

    // TODO: æsj
    if (from!.isStopPlace() && to!.isStopPlace()) {
      query = Queries().tripFromPlaceToPlace(
          from!.properties.id, to!.properties.id, excludeFilter);
    } else if (from!.isStopPlace()) {
      query = Queries().tripFromPlaceToCoordinates(
          from!.properties.id, to!.geometry.coordinates!, excludeFilter);
    } else if (to!.isStopPlace()) {
      query = Queries().tripFromCoordinatesToPlace(
          from!.geometry.coordinates!, to!.properties.id, excludeFilter);
    } else {
      query = Queries().tripFromCoordinatesToCoordinates(
          from!.geometry.coordinates!,
          to!.geometry.coordinates!,
          excludeFilter);
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({'query': query}),
    );

    return TripResponse.fromJson(jsonDecode(response.body));
  }

  _saveTrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'tripNSR', '${from!.properties.id} - ${to!.properties.id}');
    await prefs.setString(
        'tripName', '${from!.properties.name} - ${to!.properties.name}');
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
                onFromTap: () =>
                    _navigateSearch(context, from?.properties.name).then(
                  (value) {
                    if (value == null) {
                      return;
                    }
                    setState(
                      () {
                        from = value;
                      },
                    );
                  },
                ),
                onToTap: () =>
                    _navigateSearch(context, to?.properties.name).then(
                  (result) {
                    if (result == null) {
                      return;
                    }
                    setState(
                      () {
                        to = result;
                      },
                    );
                  },
                ),
                onTripSelected: () => setState(
                  () {
                    tripResponse = getTrip();
                  },
                ),
                fromName: from?.properties.name,
                toName: to?.properties.name,
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
                        _saveTrip(),
                        Fluttertoast.showToast(
                            msg: "Trip saved",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 2,
                            backgroundColor: Color(0xFFB1D2EC),
                            textColor: Colors.black,
                            webPosition: "center",
                            webBgColor:
                                "linear-gradient(to right, #FF64B5F6, #FFB1D2EC)",
                            fontSize: 16.0)
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
              SizedBox(height: 10.0),
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
