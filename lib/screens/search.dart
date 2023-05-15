import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:retur/models/searchresponse.dart';
import 'package:retur/utils/queries.dart';
import 'package:retur/widgets/locationitemcard.dart';

import '../models/favourite.dart';

class Search extends StatefulWidget {
  final String? locationName;
  const Search({super.key, this.locationName});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late String baseUrl;
  late TextEditingController textController;
  Future<SearchResponse>? searchResponse;

  @override
  void initState() {
    super.initState();
    baseUrl = "https://api.entur.io/geocoder/v1";
    textController = TextEditingController(text: widget.locationName);
    textController.addListener(
      () {
        if (textController.text.isEmpty) {
          return;
        }

        setState(() {
          searchResponse = _get(textController.text);
        });
      },
    );
  }

  String getURL(String text, {String lang = "no", int size = 20}) {
    return "$baseUrl/autocomplete?lang=$lang&text=$text&size=$size";
  }

  Future<SearchResponse> _get(String text) async {
    final url = getURL(text);
    final headers = Queries().headers;

    final response = await http.get(Uri.parse(url), headers: headers);
    return SearchResponse.fromJson(jsonDecode(response.body));
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
                    icon: Icon(Icons.arrow_back_ios_new),
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
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
                        itemCount: features.length,
                        itemBuilder: (context, index) {
                          return LocationCard(
                            feature: features[index],
                            onTap: () => Navigator.pop(context,
                                StopPlace.fromFeature(features[index])),
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
