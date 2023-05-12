import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:localstorage/localstorage.dart';

import '../models/favourite.dart';
import '../utils/transportmodes.dart';

class WidgetData {
  final FavouriteStop from;
  final FavouriteStop to;
  final Set<TransportMode> filter;

  WidgetData(this.from, this.to, this.filter);
}

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  final LocalStorage storage = LocalStorage("favourites.json");
  List<Favourite> favourites = [];
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              FutureBuilder(
                future: storage.ready,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return CircularProgressIndicator();
                  }

                  if (!initialized) {
                    List<dynamic> items = storage.getItem('favourites') ?? [];
                    favourites =
                        items.map((f) => Favourite.fromJson(f)).toList();
                    initialized = true;
                  }

                  return Expanded(
                    child: ListView.builder(
                      itemCount: favourites.length,
                      itemBuilder: ((context, index) {
                        return FavouriteCard(favourite: favourites[index]);
                      }),
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  print(jsonEncode(favourites[0]));
                  WidgetKit.setItem("widgetData", jsonEncode(favourites[0]),
                      'group.returwidget');
                  WidgetKit.reloadAllTimelines();
                },
                child: Text("Push data to widget"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavouriteCard extends StatelessWidget {
  final Favourite favourite;

  const FavouriteCard({
    super.key,
    required this.favourite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text("${favourite.from.name} - ${favourite.to.name}")),
    );
  }
}
