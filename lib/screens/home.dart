import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  String _tripNSR = 'No trip nsr saved';
  String _tripName = 'No favourite trip saved';

  final data = WidgetData(
      from: "Carl Berners plass",
      to: "Jernbanetorget",
      startTime: "2023-05-10T09:20:30+02:00",
      endTime: "2023-05-10T09:32:30+02:00");

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  _loadTrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tripNSR = (prefs.getString('tripNSR') ?? 'No trip NSR saved');
      _tripName = (prefs.getString('tripName') ?? 'No favourite trip saved');
    });
  }

  _removeTrip() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('tripName');
    _loadTrip();
  }

  @override
  Widget build(BuildContext context) {
    if (_tripName.isEmpty) {
      return Text('No trip saved');
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                margin: EdgeInsets.only(bottom: 15.0),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_tripName',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          IconButton(
                            onPressed: () => _removeTrip(),
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  WidgetKit.setItem(
                      "widgetData", jsonEncode(data), 'group.returwidget');
                  WidgetKit.reloadAllTimelines();
                },
                child: Text("Send data to widget"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WidgetLeg {
  String mode;
  int duration;
  int? line;

  WidgetLeg({required this.mode, required this.duration, this.line});
}

class WidgetData {
  late String from;
  late String to;
  late String startTime;
  late String endTime;

  WidgetData(
      {required this.from,
      required this.to,
      required this.startTime,
      required this.endTime});

  WidgetData.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = Map<String, dynamic>();
    json['from'] = from;
    json['to'] = to;
    json['startTime'] = startTime;
    json['endTime'] = endTime;
    return json;
  }
}
