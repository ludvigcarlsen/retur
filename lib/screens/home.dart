import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/searchresponse.dart';
import '../models/tripresponse.dart';
import '../utils/queries.dart';
import '../utils/transportmodes.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

String utcTohhmm(String utc) {
  DateTime dateTime = DateTime.parse(utc);
  return DateFormat('HH:mm', 'en_US').format(dateTime.toLocal());
}

class _Home extends State<Home> {
  
  Future<TripResponse>? tripResponse;
 
  List<String>? _favoriteTrip = [];

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  _loadTrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _favoriteTrip = (prefs.getStringList('favoriteTrip') ?? <String>[]);

   

    if (_favoriteTrip != null && _favoriteTrip!.length >= 2) {
      setState(() {
        tripResponse = getTrip(_favoriteTrip![0], _favoriteTrip![1]);
      });
    } else {
    
    }
  }

  _removeTrip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favoriteTrip');
    setState(() {
      tripResponse = null;
    });
  }

  Future<TripResponse> getTrip(String to, String from) async {
    final String baseUrl = Queries().journeyPlannerV3BaseUrl;
    final headers = Queries().headers;
    final Set<TransportMode> excludeFilter = {};

    final String query =
        Queries().tripFromPlaceToPlace(from, to, excludeFilter);

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
            children: <Widget>[
              const SizedBox(height: 10),
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
                            print(patterns.first.expectedStartTime);
                            print(patterns.first.expectedEndTime);
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'From: ${_favoriteTrip![2].toString()}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'To: ${_favoriteTrip![3].toString()}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          utcTohhmm(patterns[index].expectedStartTime!) ,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Container(
                                          height: 1,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          utcTohhmm(patterns[index].expectedEndTime!) ,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/bus.svg',
                                          height: 15,
                                          width: 15,
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                        ),
                                      ],
                                    ),
                                  ],
                                  
                                ),
                              ),
                            );
                            
                          },
                        ),
                      );
                    }
                    return Container();
                  }),
              IconButton(
                onPressed: () => _removeTrip(),
                icon: Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
