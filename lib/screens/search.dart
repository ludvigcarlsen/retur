import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:retur/models/searchresponse.dart';
import 'package:retur/utils/debouncer.dart';
import 'package:retur/utils/queries.dart';
import 'package:retur/widgets/locationitemcard.dart';

import '../models/tripdata.dart';

class Search extends StatefulWidget {
  final String? locationName;
  const Search({super.key, this.locationName});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late TextEditingController textController;
  Future<SearchResponse>? searchResponse;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    textController = TextEditingController(text: widget.locationName);
    textController.addListener(
      () {
        if (textController.text.isEmpty) {
          return;
        }

        _debouncer.run(
          () {
            setState(() {
              searchResponse = _search(textController.text);
            });
          },
        );
      },
    );
  }

  String getURL(String text, {String lang = "no", int size = 20}) {
    return "${Queries.geocoderBaseUrl}/autocomplete?lang=$lang&text=$text&size=$size";
  }

  Future<SearchResponse> _search(String text) async {
    final url = getURL(text);
    final headers = Queries.headers;

    final response = await http.get(Uri.parse(url), headers: headers);
    return SearchResponse.fromJson(jsonDecode(response.body));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () => Navigator.pop(context, null),
                    icon: const Icon(Icons.arrow_back_ios_new),
                    iconSize: 20,
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: IconButton(
                          onPressed: textController.clear,
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              FutureBuilder(
                future: searchResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    final features = snapshot.data!.features;

                    return Expanded(
                      child: ListView.builder(
                        itemCount: features.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return FutureBuilder(
                              future: Geolocator.isLocationServiceEnabled(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: LocationButton(
                                      onPressed: () =>
                                          _determinePosition().then((position) {
                                        final stop = StopPlace(
                                            null,
                                            "Your location",
                                            position.latitude,
                                            position.longitude);
                                        Navigator.pop(context, stop);
                                      }).catchError(
                                              // TODO: handle error
                                              (error) => debugPrint(error)),
                                    ),
                                  );
                                }
                                return Container();
                              },
                            );
                          }
                          return LocationCard(
                            feature: features[index - 1],
                            onTap: () => Navigator.pop(context,
                                StopPlace.fromFeature(features[index - 1])),
                          );
                        },
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationButton extends StatelessWidget {
  final void Function()? onPressed;

  const LocationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Row(
            children: [
              Icon(Icons.near_me, size: 16),
              SizedBox(width: 5),
              Text("Your location")
            ],
          ),
        ),
      ),
    );
  }
}
