import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:retur/models/trip_settings.dart';

class TripSettingsView extends StatelessWidget {
  final TripSettings settings;
  final Future<bool> Function(bool) onDynamicTripToggle;

  TripSettingsView(
      {super.key, required this.settings, required this.onDynamicTripToggle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        AsyncToggle(
          text: "Dynamic journey",
          description: "Swap locations based on your current location",
          value: settings.isDynamicTrip,
          onChanged: (value) => onDynamicTripToggle(value)
              .then((newValue) => settings.isDynamicTrip = newValue),
        ),
        const SizedBox(height: 10),
        AsyncToggle(
            text: "Include walk to first stop",
            value: settings.includeFirstWalk,
            onChanged: (value) {
              settings.includeFirstWalk = value;
              return Future<bool>.value(value);
            }),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, settings),
          child: const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("Confirm"),
          ),
        ),
      ],
    );
  }
}

class AsyncToggle extends StatefulWidget {
  final String text;
  final String? description;
  final Future<bool> Function(bool) onChanged;
  bool value;

  AsyncToggle(
      {super.key,
      required this.value,
      required this.text,
      this.description,
      required this.onChanged});

  @override
  State<AsyncToggle> createState() => _AsyncToggleState();
}

class _AsyncToggleState extends State<AsyncToggle> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.text),
          widget.description == null
              ? Container()
              : Text(
                  widget.description!,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                )
        ]),
        const Spacer(),
        CupertinoSwitch(
          activeColor: const Color.fromARGB(255, 81, 154, 255),
          value: widget.value,
          onChanged: (bool value) {
            widget.onChanged(value).then(
              (asyncValue) {
                setState(() {
                  widget.value = asyncValue;
                });
              },
            );
          },
        ),
      ],
    );
  }
}
