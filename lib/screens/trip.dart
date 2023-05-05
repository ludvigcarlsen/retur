import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:retur/models/searchresponse.dart';
import 'package:retur/models/tripresponse.dart';
import 'package:retur/screens/search.dart';
import 'package:http/http.dart' as http;
import 'package:retur/widgets/locationitemcard.dart';
import 'package:retur/widgets/tripitemcard.dart';

import '../utils/queries.dart';
import '../widgets/tripinputcard.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  Future<TripResponse>? tripResponse;
  Feature? from;
  Feature? to;

  Future<Feature?> _navigateAndFetchResult(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Search(),
      ),
    );
  }

  Future<TripResponse> getTrip() async {
    final String baseUrl = Queries().journeyPlannerV3BaseUrl;
    final headers = Queries().headers;
    final String query =
        Queries().tripByPlace(from!.properties.id, to!.properties.id);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({'query': query}),
    );
    return TripResponse.fromJson(jsonDecode(response.body));
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
                onFromTap: () => _navigateAndFetchResult(context).then(
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
                onToTap: () => _navigateAndFetchResult(context).then(
                  (value) {
                    if (value == null) {
                      return;
                    }
                    setState(
                      () {
                        to = value;
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
                      onPressed: () => print("test"),
                      child: Row(
                        children: [Icon(Icons.tune), Text("Filter")],
                      ),
                    ),
                  ),
                  SizedBox(width: 15.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => print("test"),
                      child: Row(
                        children: [Text("Save")],
                      ),
                    ),
                  ),
                ],
              ),
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
