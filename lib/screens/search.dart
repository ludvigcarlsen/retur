import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:retur/models/searchresponse.dart';
import 'package:retur/widgets/locationitemcard.dart';

class Search extends StatefulWidget {
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final baseUrl = "https://api.entur.io/geocoder/v1";
  final textController = TextEditingController();
  Future<SearchResponse>? searchResponse;

  String getURL(String text, {String lang = "no", int size = 20}) {
    return "$baseUrl/autocomplete?lang=$lang&text=$text&size=$size";
  }

  Future<SearchResponse> _get(String text) async {
    final url = getURL(text);
    final headers = {
      'Content-Type': 'application/json',
      'ET-Client-Name': 'ludvigcarlsen-retur'
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    return SearchResponse.fromJson(jsonDecode(response.body));
  }

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, null),
                    icon: Icon(Icons.arrow_back_ios_new),
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
                          return InkWell(
                            onTap: () =>
                                Navigator.pop(context, features[index]),
                            child: LocationCard(
                              feature: features[index],
                            ),
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
