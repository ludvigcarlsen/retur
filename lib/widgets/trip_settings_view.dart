import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:retur/models/trip_settings.dart';

class TripSettingsView extends StatelessWidget {
  final TripSettings settings;

  TripSettingsView({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        ToggleSetting(
          description: "Dynamic trip",
          value: settings.isDynamicTrip,
          onChanged: (value) => settings.isDynamicTrip = value,
        ),
        const SizedBox(height: 10),
        ToggleSetting(
          description: "Include walk to first stop",
          value: settings.includeFirstWalk,
          onChanged: (value) => settings.includeFirstWalk = value,
        ),
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

class ToggleSetting extends StatefulWidget {
  final String description;
  final Function(bool) onChanged;
  bool value;

  ToggleSetting(
      {super.key,
      required this.value,
      required this.description,
      required this.onChanged});

  @override
  State<ToggleSetting> createState() => _ToggleSettingState();
}

class _ToggleSettingState extends State<ToggleSetting> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.description),
        Spacer(),
        CupertinoSwitch(
          activeColor: const Color.fromARGB(255, 81, 154, 255),
          value: widget.value,
          onChanged: (bool value) {
            widget.onChanged(value);
            setState(() {
              widget.value = value;
            });
          },
        ),
      ],
    );
  }
}
